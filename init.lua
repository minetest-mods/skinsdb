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

-- ie.loadfile does not exist?
skins.ie = minetest.request_insecure_environment()
skins.http = minetest.request_http_api()
dofile(skins.modpath.."/skins_updater.lua")
skins.ie = nil
skins.http = nil

-- 3d_armor compatibility
if minetest.global_exists("armor") then
	skins.armor_loaded = true
	armor.get_player_skin = function(self, name)
		local skin = skins.get_player_skin(minetest.get_player_by_name(name))
		return skin:get_texture()
	end
	armor.get_preview = function(self, name)
		local skin = skins.get_player_skin(minetest.get_player_by_name(name))
		return skin:get_preview()
	end
	armor.update_player_visuals = function(self, player)
		if not player then
			return
		end
		local skin = skins.get_player_skin(player)
		skin:apply_skin_to_player(player)
		armor:run_callbacks("on_update", player)
	end
end

if minetest.global_exists("clothing") and clothing.player_textures then
	skins.clothing_loaded = true
	clothing:register_on_update(skins.update_player_skin)
end

-- Update skin on join
skins.ui_context = {}
minetest.register_on_joinplayer(function(player)
	skins.update_player_skin(player)
end)

minetest.register_on_leaveplayer(function(player)
	skins.ui_context[player:get_player_name()] = nil
end)

if minetest.global_exists("player_api") then
	-- Minetest-5 and above compatible
	player_api.register_model("skinsdb_3d_armor_character_5.b3d", {
		animation_speed = 30,
		textures = {
			"blank.png",
			"blank.png",
			"blank.png",
			"blank.png"
		},
		animations = {
			stand = {x=0, y=79},
			lay = {x=162, y=166},
			walk = {x=168, y=187},
			mine = {x=189, y=198},
			walk_mine = {x=200, y=219},
			sit = {x=81, y=160},
		},
	})
else
	-- Minetest-0.4 compatible
	default.player_register_model("skinsdb_3d_armor_character.b3d", {
		animation_speed = 30,
		textures = {
			"blank.png",
			"blank.png",
			"blank.png",
			"blank.png",
		},
		animations = {
			stand = {x=0, y=79},
			lay = {x=162, y=166},
			walk = {x=168, y=187},
			mine = {x=189, y=198},
			walk_mine = {x=200, y=219},
			sit = {x=81, y=160},
		},
	})
end
