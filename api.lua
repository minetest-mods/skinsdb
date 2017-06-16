-- get current skin
skins.get_player_skin = function(player)
	local skin = player:get_attribute("skin")
	if not skins.textures[skin] then
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

-- 3d_armor compatibility
if minetest.global_exists("armor") then
	armor.get_player_skin = function(self, name)
		return skins.get_player_skin(minetest.get_player_by_name(name))
	end
	armor.get_preview = function(self, name)
		return skins.preview[skins.get_player_skin(minetest.get_player_by_name(name))]
	end
end
