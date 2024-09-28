local dbgprint = false and print or function() end

--- @param path     Path to the "textures" directory, without tailing slash.
--- @param filename Current file name, such as "player.groot.17.png".
--- @return On error: false, error message. On success: true, skin key
function skins.register_skin(path, filename)
	-- See "textures/readme.txt" for allowed formats

	local prefix, sep, identifier, extension = filename:match("^(%a+)([_.])([%w_.-]+)%.(%a+)$")
	--[[
		prefix:     "character" or "player"
		sep:        "." (new) or "_" (legacy)
		identifier: number, name or (name + sep + number)
			^ previews are explicity skipped
		extension:  "png" only due `skins.get_skin_format`
	]]

	-- Filter out files that do not match the allowed patterns
	if not extension or extension:lower() ~= "png" then
		return false, "invalid skin name"
	end
	if prefix ~= "player" and prefix ~= "character" then
		return false, "unknown type"
	end

	local preview_suffix = sep .. "preview"
	if identifier:sub(-#preview_suffix) == preview_suffix then
		-- The preview texture is added by the main skin texture (if exists)
		return false, "preview texture"
	end

	assert(path)
	if path == ":UNITTEST:" then
		path = nil
	end

	dbgprint("Found skin", prefix, identifier, extension)

	local sort_id    -- number, sorting "rank" in the skin list
	local playername -- string, if player-specific
	if prefix == "player" then
		-- Allow "player.PLAYERNAME.png" and "player.PLAYERNAME.123.png"
		local splits = identifier:split(sep)

		playername = splits[1]
		-- Put in front
		sort_id = 0 + (tonumber(splits[2]) or 0)

		if #splits > 1 and sep == "_" then
			minetest.log("warning", "skinsdb: The skin name '" .. filename .. "' is ambigous." ..
				" Please use the separator '.' to lock it down to the correct player name.")
		end
	else -- Public skin "character*"
		-- Less priority
		sort_id = 5000 + (tonumber(identifier) or 0)
	end

	local filename_noext = prefix .. sep .. identifier

	dbgprint("Register skin", filename_noext, playername, sort_id)

	-- Register skin texture
	local skin_obj = skins.get(filename_noext) or skins.new(filename_noext)
	skin_obj:set_texture(filename)
	skin_obj:set_meta("_sort_id", sort_id)
	if sep ~= "_" then
		skin_obj._legacy_name = filename_noext:gsub("[._]+", "_")
	end

	if playername then
		skin_obj:set_meta("assignment", "player:"..playername)
		skin_obj:set_meta("playername", playername)
	end

	if path then
		-- Get type of skin based on dimensions
		local file = io.open(path .. "/" .. filename, "r")
		local skin_format = skins.get_skin_format(file)
		skin_obj:set_meta("format", skin_format)
		file:close()
	end

	skin_obj:set_hand_from_texture()
	skin_obj:set_meta("name", identifier)

	if path then
		-- Optional skin information
		local file = io.open(path .. "/../meta/" .. filename_noext .. ".txt", "r")
		if file then
			dbgprint("Found meta")
			local data = string.split(file:read("*all"), "\n", 3)
			skin_obj:set_meta("name", data[1])
			skin_obj:set_meta("author", data[2])
			skin_obj:set_meta("license", data[3])
			file:close() -- do not rely on delayed GC
		end
	end

	if path then
		-- Optional preview texture
		local preview_name = filename_noext .. sep .. "preview.png"
		local fh = io.open(path .. "/" .. preview_name)
		if fh then
			dbgprint("Found preview", preview_name)
			skin_obj:set_preview(preview_name)
			fh:close() -- do not rely on delayed GC
		end
	end

	return true, skin_obj:get_key()
end

--- Internal function. Fallback/migration code for `.`-delimited skin names that
--- were equipped between d3c7fa7 and 312780c (master branch).
--- During this period, `.`-delimited skin names were internally registered with
--- `_` delimiters. This function tries to find a matching skin.
--- @param player_name (string)
--- @param skin_name   (string) e.g. `player_foo_mc_bar`
--- @param be_noisy    (boolean) whether to print a warning in case of mismatches`
--- @return On match, the new skin (skins.skin_class) or `nil` if nothing matched.
function skins.__fuzzy_match_skin_name(player_name, skin_name, be_noisy)
	if select(2, skin_name:gsub("%.", "")) > 0 then
		-- Not affected by ambiguity
		return
	end

	for _, skin in pairs(skins.meta) do
		if skin._legacy_name == skin_name then
			dbgprint("Match", skin_name, skin:get_key())
			return skin
		end
		--dbgprint("Try match", skin_name, skin:get_key(), skin._legacy_name)
	end

	if be_noisy then
		minetest.log("warning", "skinsdb: cannot find matching skin '" ..
			skin_name .. "' for player '" .. player_name .. "'.")
	end
end

do
	-- Load skins from the current mod directory
	local skins_path = skins.modpath.."/textures"
	local skins_dir_list = minetest.get_dir_list(skins_path)

	for _, fn in pairs(skins_dir_list) do
		skins.register_skin(skins_path, fn)
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
