-- Skins update script

local S = minetest.get_translator("skinsdb")
local _ID_ = "Lua Skins Updater"

local internal = {}
internal.errors = {}

-- Binary downloads are required
if not core.features.httpfetch_binary_data then
	internal.errors[#internal.errors + 1] =
		"Feature 'httpfetch_binary_data' is missing. Update Minetest."
end

-- Insecure environment for saving textures and meta
local ie, http = skins.ie, skins.http
if not ie or not http then
	internal.errors[#internal.errors + 1] = "Insecure environment is required. " ..
		"Please add skinsdb to `secure.trusted_mods` in minetest.conf"
end

minetest.register_chatcommand("skinsdb_download_skins", {
	params = "<skindb start page> <amount of pages>",
	description = S("Downloads the specified range of skins and shuts down the server"),
	privs = {server=true},
	func = function(name, param)
		if #internal.errors > 0 then
			return false, "Cannot run " .. _ID_ .. ":\n\t" ..
				table.concat(internal.errors, "\n\t")
		end

		local parts = string.split(param, " ")
		local start = tonumber(parts[1])
		local len = tonumber(parts[2])
		if not (start and len and len > 0) then
			return false, "Invalid page number or amount of pages"
		end

		internal.get_pages_count(internal.fetch_function, start, len)
		return true, "Started downloading..."
	end,
})


if #internal.errors > 0 then
	return -- Nonsense to load something that's not working
end

-- http://minetest.fensta.bplaced.net/api/apidoku.md
local root_url = "http://minetest.fensta.bplaced.net"
local page_url = root_url .. "/api/v2/get.json.php?getlist&page=%i&outformat=base64" -- [1] = Page#
local preview_url = root_url .. "/skins/1/%i.png" -- [1] = ID

local mod_path = skins.modpath
local meta_path = mod_path .. "/meta/"
local skins_path = mod_path .. "/textures/"

-- Fancy debug wrapper to download an URL
local function fetch_url(url, callback)
	http.fetch({
		url = url,
		user_agent = _ID_
	}, function(result)
		if result.succeeded then
			if result.code ~= 200 then
				core.log("warning", ("%s: STATUS=%i URL=%s"):format(
					_ID_, result.code, url))
			end
			return callback(result.data)
		end
		core.log("warning", ("%s: Failed to download URL=%s"):format(
			_ID_, url))
	end)
end

-- Insecure workaround since meta/ and textures/ cannot be written to
local function unsafe_file_write(path, contents)
	local f = ie.io.open(path, "wb")
	f:write(contents)
	f:close()
end

-- Takes a valid skin table from the Skins Database and saves it
local function safe_single_skin(skin)
	local meta = {
		skin.name,
		skin.author,
		skin.license
	}

	local name =  "character_" .. skin.id

	-- core.safe_file_write does not work here
	unsafe_file_write(
		meta_path .. name .. ".txt",
		table.concat(meta, "\n")
	)

	unsafe_file_write(
		skins_path .. name .. ".png",
		core.decode_base64(skin.img)
	)
	fetch_url(preview_url:format(skin.id), function(preview)
		unsafe_file_write(skins_path .. name .. "_preview.png", preview)
	end)
	core.log("action", ("%s: Completed skin %s"):format(_ID_, name))
end

-- Get total pages since it'll just return the last page all over again
internal.get_pages_count = function(callback, ...)
	local vars = {...}
	fetch_url(page_url:format(1) .. "&per_page=1", function(data)
		local list = core.parse_json(data)
		-- "per_page" defaults to 20 if left away (docs say something else, though)
		callback(math.ceil(list.pages / 20), unpack(vars))
	end)
end
	
-- Function to fetch a range of pages
internal.fetch_function = function(pages_total, start_page, len)
	start_page = math.max(start_page, 1)
	local end_page = math.min(start_page + len - 1, pages_total)

	for page_n = start_page, end_page do
		local page_cpy = page_n
		fetch_url(page_url:format(page_n), function(data)
			core.log("action", ("%s: Page %i"):format(_ID_, page_cpy))

			local list = core.parse_json(data)
			for i, skin in pairs(list.skins) do
				assert(skin.type == "image/png")
				assert(skin.id ~= "")

				if skin.id ~= 1 then -- Skin 1 is bundled with skinsdb
					safe_single_skin(skin)
				end
			end

			if page_cpy == end_page then
				local log = _ID_ .. " finished downloading all skins. " ..
					"Shutting down server to reload media cache"
				core.log("action", log)
				core.request_shutdown(log, true, 3 --[[give some time for pending requests]])
			end
		end)
	end
end
