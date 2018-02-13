minetest.register_chatcommand("skinsdb", {
	params = "[set] <skin key> | show [<skin key>] | list | list private | list public",
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
				if word == 'set' or word == 'list' or word == 'show' then
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
			return false, "see /help skinsdb for supported parameters"
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
		end


	end,
})
