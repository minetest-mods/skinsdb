-- get current skin
skins.get_player_skin = function(player)
	local skin = player:get_attribute("skin")
	return skins.get(skin) or skins.get(skins.default)
end

-- Set skin
skins.set_player_skin = function(player, skin)
	local skin_obj
	local skin_key
	if type(skin) == "string" then
		skin_obj = skins.get(skin) or skins.get(skins.default)
	else
		skin_obj = skin
	end
	skin_key = skin:get_meta("_key")

	if skin_key == skins.default then
		skin_key = ""
	end

	player:set_attribute("skin", skin_key)
	skins.update_player_skin(player)
end

-- update visuals
skins.update_player_skin = function(player)
	local skin = skins.get_player_skin(player)
	skin:set_skin(player)
end
