-- Unified Skins for Minetest - based modified Bags from unfied_inventory and skins from inventory_plus

-- Copyright (c) 2012 cornernote, Dean Montgomery
-- License: GPLv3
-- Boilerplate to support localized strings if intllib mod is installed.

skins = {}
skins.modpath = minetest.get_modpath("skins")
skins.file = minetest.get_worldpath().."skins.mt"
skins.default = "character_1"
skins.pages = {}
skins.skins = {}
skins.file_save = false

skins.type = { SPRITE=0, MODEL=1, ERROR=99 }
skins.get_type = function(texture)
	if not skins.is_skin(texture) then
		return skins.type.ERROR
	end
	return skins.type.MODEL
end

skins.is_skin = function(texture)
	if not texture then
		return false
	end
	if not skins.meta[texture] then
		return false
	end
	return true
end

dofile(skins.modpath.."/skinlist.lua")
dofile(skins.modpath.."/players.lua")


skins.update_player_skin = function(player)
	local name = player:get_player_name()

	if not skins.is_skin(skins.skins[name]) then
		skins.skins[name] = skins.default
	end
	player:set_properties({
		textures = {skins.skins[name]..".png"},
	})
end

-- Unified inventory page/integration
if minetest.get_modpath("unified_inventory") then
	dofile(skins.modpath.."/unified_inventory_page.lua")
end

-- Change skin on join - reset if invalid
minetest.register_on_joinplayer(function(player)
	local player_name = player:get_player_name()
	if not skins.is_skin(skins.skins[player_name]) then
		skins.skins[player_name] = skins.default
	end
	skins.update_player_skin(player)
end)


