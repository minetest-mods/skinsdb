-- get current skin
skins.get_player_skin = function(player)
	local skin = player:get_attribute("skin")
	if not skins.is_skin(skin) then
		skin = skins.default
	end
	return skin
end

-- Set skin
skins.set_player_skin = function(player, skin)
	if skin == skins.default then
		skin = ""
	end
	player:set_attribute("skin", skin)
	skins.update_player_skin(player)
end

-- update visuals
skins.update_player_skin = function(player)
	local skin = skins.get_player_skin(player)
	player:set_properties({
		textures = {skins.textures[skin]},
	})
end

-- Update skin on join
minetest.register_on_joinplayer(function(player)
	skins.update_player_skin(player)
end)
