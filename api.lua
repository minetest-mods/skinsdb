-- get current skin
function skins.get_player_skin(player)
	local skin = player:get_attribute("skinsdb:skin_key")
	return skins.get(skin) or skins.get(skins.default)
end

-- Assign skin to player
function skins.assign_player_skin(player, skin)
	local skin_obj
	local skin_key
	if type(skin) == "string" then
		skin_obj = skins.get(skin) or skins.get(skins.default)
	else
		skin_obj = skin
	end
	skin_key = skin_obj:get_key()

	if skin_key == skins.default then
		skin_key = ""
	end
	player:set_attribute("skinsdb:skin_key", skin_key)
end

-- update visuals
function skins.update_player_skin(player)
	local skin = skins.get_player_skin(player)
	skin:set_skin(player)
end

-- Assign and update
function skins.set_player_skin(player, skin)
	skins.assign_player_skin(player, skin)
	skins.update_player_skin(player)
end
