local dbgprint = false and print or function() end

--- @param path     Path to the "textures" directory, without tailing slash.
--- @param filename Current file name, such as "player.groot.17.png".
local function process_skin_texture(path, filename)
	-- See "textures/readme.txt" for allowed formats

	local prefix, sep, middlepart, extension = filename:match("^(%w+)([_.])(.*)%.(%w+)$")
	--[[
		prefix:     "character" or "player"
		sep:        "." (new) or "_" (legacy)
		middlepart: number or name
			^ previews are explicity skipped
		extension:  "png" only due `skins.get_skin_format`
	]]

	-- Filter out files that do not match the allowed patterns
	if not extension or extension:lower() ~= "png" then
		return -- Not a skin texture
	end
	if prefix ~= "player" and prefix ~= "character" then
		return -- Unknown type
	end

	local preview_suffix = sep .. "preview"
	if middlepart:sub(-#preview_suffix) == preview_suffix then
		-- skip preview textures
		-- This is added by the main skin texture (if exists)
		return
	end

	dbgprint("Found skin", prefix, middlepart, extension)

	local sort_id    -- number, sorting "rank" in the skin list
	local playername -- string, if player-specific
	if prefix == "player" then
		-- Allow "player.PLAYERNAME.png" and "player.PLAYERNAME.123.png"
		local splits = middlepart:split(sep)
		playername = splits[1]

		-- Put in front
		sort_id = 0 + (tonumber(splits[2]) or 0)
	else -- Public skin "character*"
		-- Less priority
		sort_id = 5000 + (tonumber(middlepart) or 0)
	end

	local filename_noext = prefix .. sep .. middlepart

	-- Register skin texture
	local skin_obj = skins.get(filename_noext) or skins.new(filename_noext)
	skin_obj:set_texture(filename)
	skin_obj:set_meta("_sort_id", sort_id)
	if playername then
		skin_obj:set_meta("assignment", "player:"..playername)
		skin_obj:set_meta("playername", playername)
	end

	do
		-- Get type of skin based on dimensions
		local file = io.open(path .. "/" .. filename, "r")
		local skin_format = skins.get_skin_format(file)
		skin_obj:set_meta("format", skin_format)
		file:close()
	end

	skin_obj:set_hand_from_texture()
	skin_obj:set_meta("name", middlepart)

	do
		-- Optional skin information
		local file = io.open(path .. "/../meta/" .. filename_noext .. ".txt", "r")
		if file then
			dbgprint("Found meta")
			local data = string.split(file:read("*all"), "\n", 3)
			skin_obj:set_meta("name", data[1])
			skin_obj:set_meta("author", data[2])
			skin_obj:set_meta("license", data[3])
		end
	end

	do
		-- Optional preview texture
		local preview_name = filename_noext .. sep .. "preview.png"
		local fh = io.open(path .. "/" .. preview_name)
		if fh then
			dbgprint("Found preview", preview_name)
			skin_obj:set_preview(preview_name)
		end
	end
end

do
	-- Load skins from the current mod directory
	local skins_path = skins.modpath.."/textures"
	local skins_dir_list = minetest.get_dir_list(skins_path)

	for _, fn in pairs(skins_dir_list) do
		process_skin_texture(skins_path, fn)
	end
end

local function skins_sort(skinslist)
	table.sort(skinslist, function(a,b)
		local a_id = a:get_meta("_sort_id") or 10000
		local b_id = b:get_meta("_sort_id") or 10000
		if a_id ~= b_id then
			return a_id < b_id
		else
			return (a:get_meta("name") or 'ZZ') < (b:get_meta("name") or 'ZZ')
		end
	end)
end

-- (obsolete) get skinlist. If assignment given ("mod:wardrobe" or "player:bell07") select skins matches the assignment. select_unassigned selects the skins without any assignment too
function skins.get_skinlist(assignment, select_unassigned)
	minetest.log("deprecated", "skins.get_skinlist() is deprecated. Use skins.get_skinlist_for_player() instead")
	local skinslist = {}
	for _, skin in pairs(skins.meta) do
		if not assignment or
				assignment == skin:get_meta("assignment") or
				(select_unassigned and skin:get_meta("assignment") == nil) then
			table.insert(skinslist, skin)
		end
	end
	skins_sort(skinslist)
	return skinslist
end

-- Get skinlist for player. If no player given, public skins only selected
function skins.get_skinlist_for_player(playername)
	local skinslist = {}
	for _, skin in pairs(skins.meta) do
		if skin:is_applicable_for_player(playername) and skin:get_meta("in_inventory_list") ~= false then
			table.insert(skinslist, skin)
		end
	end
	skins_sort(skinslist)
	return skinslist
end

-- Get skinlist selected by metadata
function skins.get_skinlist_with_meta(key, value)
	assert(key, "key parameter for skins.get_skinlist_with_meta() missed")
	local skinslist = {}
	for _, skin in pairs(skins.meta) do
		if skin:get_meta(key) == value then
			table.insert(skinslist, skin)
		end
	end
	skins_sort(skinslist)
	return skinslist
end
