local function show_selection_formspec(player)
	local context = skins.ui_context[player:get_player_name()]
	local name = player:get_player_name()
	local skin = skins.get_player_skin(player)
	local formspec = "size[8,8]"..skins.get_skin_info_formspec(skin)
	formspec = formspec..skins.get_skin_selection_formspec(player, context, 3.5)
	minetest.show_formspec(name, 'skinsdb_show_ui', formspec)
end


minetest.register_chatcommand("skinsdb", {
	params = "[set] <skin key> | show [<skin key>] | list | list private | list public | [ui]",
	description = "Set, show or list player's skin",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "Player not found"
		end

		-- parse command line
		local command, parameter
		for word in param:gmatch("([^ ]+)") do
			if not command then
				-- first word
				if word == 'set' or word == 'list' or word == 'show' or word == 'ui' then
					command = word
				elseif skins.get(word) then
					command = 'set'
					parameter = word
					break
				else
					return false, "unknown command "..word.." see /help skinsdb for supported parameters"
				end
			else
				-- second word
				parameter = word
				break
			end
		end
		if not command then
			command = "ui"
		end

		if command == "set" then
			local success = skins.set_player_skin(player, parameter)
			if success then
				return true, "skin set to "..parameter
			else
				return false, "invalid skin "..parameter
			end
		elseif command == "list" then
			local list
			if parameter == "private" then
				list = skins.get_skinlist_with_meta("playername", name)
			elseif parameter == "public" then
				list = skins.get_skinlist_for_player()
			elseif not parameter then
				list = skins.get_skinlist_for_player(name)
			else
				return false, "unknown parameter", parameter
			end

			local current_skin_key = skins.get_player_skin(player):get_key()
			for _, skin in ipairs(list) do
				local info = skin:get_key()..": name="..skin:get_meta_string("name").." author="..skin:get_meta_string("author").." license="..skin:get_meta_string("license")
				if skin:get_key() == current_skin_key then
					info = minetest.colorize("#00FFFF", info)
				end
				minetest.chat_send_player(name, info)
			end
		elseif command == "show" then
			local skin
			if parameter then
				skin = skins.get(parameter)
			else
				skin = skins.get_player_skin(player)
			end
			if not skin then
				return false, "unknown skin"
			end
			local formspec = "size[8,3]"..skins.get_skin_info_formspec(skin)
			minetest.show_formspec(name, 'skinsdb_show_skin', formspec)
		elseif command == "ui" then
			show_selection_formspec(player)
		end
	end,
})


minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "skinsdb_show_ui" then
		return
	end

	local context = skins.ui_context[player:get_player_name()]

	local action = skins.on_skin_selection_receive_fields(player, context, fields)
	if action == 'set' then
		minetest.close_formspec(player:get_player_name(), formname)
	elseif action == 'page' then
		show_selection_formspec(player)
	end
end)
