-- Skins update script
-- Load it in init.lua or write a frontend GUI/chatcommand for it. Good luck.

local _ID_ = "Lua Skins Updater"
local _SKIN_PAGE_START_ = 1   -- Starting page to fetch the skins
local _SKIN_PAGE_END_   = nil -- End page number (nil = all skins)

if not core.features.httpfetch_binary_data then
	error(_ID_ .. " requires the feature 'httpfetch_binary_data'. Update Minetest.")
end

local ie, http = skins.ie, skins.http
if not ie or not http then
	error(_ID_ .. " requires the insecure environment. " ..
		"Please add skinsdb to `secure.trusted_mods` in minetest.conf")
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
	local f = ie.io.open(path, "w")
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
local function get_pages_count(callback)
	fetch_url(page_url:format(1) .. "&per_page=5", function(data)
		local list = core.parse_json(data)
		print(dump(list))
		callback(list.pages)
	end)
end
	
-- Just fetch them all. YOLO
get_pages_count(function(pages_total)
	local start_page = _SKIN_PAGE_START_ or 1
	local end_page = math.min(pages_total, _SKIN_PAGE_END_ or pages_total)

	for page_n = 1, end_page do
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
				core.log("action", _ID_ .. " finished downloading all skins. " ..
					"Please comment out this script to reduce server traffic.")
				core.request_shutdown("Reloading skinsdb media cache after download",
					true, 3 --[[give some time for pending requests]])
			end
		end)
	end
end)