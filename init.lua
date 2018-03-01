-- Unified Skins for Minetest - based modified Bags from unfied_inventory and skins from inventory_plus

-- Copyright (c) 2012 cornernote, Dean Montgomery
-- Rework 2017 by bell07
-- License: GPLv3
-- Boilerplate to support localized strings if intllib mod is installed.

skins = {}
skins.modpath = minetest.get_modpath(minetest.get_current_modname())
skins.default = "character"

local S
if minetest.get_modpath("intllib") then
	skins.S = intllib.Getter()
else
	skins.S = function(s) return s end
end


dofile(skins.modpath.."/skin_meta_api.lua")
dofile(skins.modpath.."/api.lua")
dofile(skins.modpath.."/skinlist.lua")
dofile(skins.modpath.."/formspecs.lua")
dofile(skins.modpath.."/chatcommands.lua")
-- Unified inventory page/integration
if minetest.get_modpath("unified_inventory") then
	dofile(skins.modpath.."/unified_inventory_page.lua")
end

if minetest.get_modpath("sfinv") then
	dofile(skins.modpath.."/sfinv_page.lua")
end

-- 3d_armor compatibility
if minetest.global_exists("armor") then
	armor.get_player_skin = function(self, name)
		local skin = skins.get_player_skin(minetest.get_player_by_name(name))
		return skin:get_texture()
	end
	armor.get_preview = function(self, name)
		local skin = skins.get_player_skin(minetest.get_player_by_name(name))
		return skin:get_preview()
	end
end

-- Update skin on join
skins.ui_context = {}
minetest.register_on_joinplayer(function(player)
	skins.update_player_skin(player)
end)

minetest.register_on_leaveplayer(function(player)
	skins.ui_context[player:get_player_name()] = nil
end)
