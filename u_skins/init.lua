-- Unified Skins for Minetest - based modified Bags from unfied_inventory and skins from inventory_plus

-- Copyright (c) 2012 cornernote, Dean Montgomery
-- License: GPLv3
u_skins = {}
u_skins.modpath = minetest.get_modpath("u_skins")
u_skins.file = minetest.get_worldpath().."/u_skins.mt"
u_skins.default = "character_1"
u_skins.pages = {}
u_skins.u_skins = {}
u_skins.file_save = false
u_skins.simple_skins = false

-- ( Deprecated
u_skins.type = { SPRITE=0, MODEL=1, ERROR=99 }
u_skins.get_type = function(texture)
	if not u_skins.is_skin(texture) then
		return u_skins.type.ERROR
	end
	return u_skins.type.MODEL
end
-- )

u_skins.is_skin = function(texture)
	if not texture then
		return false
	end
	if not u_skins.meta[texture] then
		return false
	end
	return true
end

dofile(u_skins.modpath.."/skinlist.lua")
dofile(u_skins.modpath.."/players.lua")

if rawget(_G, "skins") then
	u_skins.simple_skins = true
end

u_skins.update_player_skin = function(player)
	local name = player:get_player_name()
	if u_skins.simple_skins and u_skins.u_skins[name] == u_skins.default then
		return
	end
	
	if not u_skins.is_skin(u_skins.u_skins[name]) then
		u_skins.u_skins[name] = u_skins.default
	end
	player:set_properties({
		textures = {u_skins.u_skins[name]..".png"},
	})
end

-- Display Current Skin
unified_inventory.register_page("u_skins", {
	get_formspec = function(player)
		local name = player:get_player_name()
		if not u_skins.is_skin(u_skins.u_skins[name]) then
			u_skins.u_skins[name] = u_skins.default
		end
		
		local formspec = ("background[0.06,0.99;7.92,7.52;ui_misc_form.png]"
			.."image[0,.75;1,2;"..u_skins.u_skins[name].."_preview.png]"
			.."label[6,.5;Raw texture:]"
			.."image[6,1;2,1;"..u_skins.u_skins[name]..".png]")
				
		local meta = u_skins.meta[u_skins.u_skins[name]]
		if meta then
			if meta.name ~= "" then
				formspec = formspec.."label[2,.5;Name: "..minetest.formspec_escape(meta.name).."]"
			end
			if meta.author ~= "" then
				formspec = formspec.."label[2,1;Author: "..minetest.formspec_escape(meta.author).."]"
			end
			if meta.license ~= "" then
				formspec = formspec.."label[2,1.5;License: "..minetest.formspec_escape(meta.license).."]"
			end
			if meta.description ~= "" then --what's that??
				formspec = formspec.."label[2,2;Description: "..minetest.formspec_escape(meta.description).."]"
			end
		end
		local page = 0
		if u_skins.pages[name] then
			page = u_skins.pages[name]
		end
		formspec = formspec .. "button[.75,3;6.5,.5;u_skins_page$"..page..";Change]"
		return {formspec=formspec}
	end,
})

unified_inventory.register_button("u_skins", {
	type = "image",
	image = "u_skins_button.png",
})

-- Create all of the skin-picker pages.

u_skins.generate_pages = function(texture)
	local page = 0
	local pages = {}
	for i, skin in ipairs(u_skins.list) do
		local p_index = (i - 1) % 16
		if p_index == 0 then
			page = page + 1
			pages[page] = {}
		end
		pages[page][p_index + 1] = {i, skin}
	end
	local total_pages = page
	page = 1
	for page, arr in ipairs(pages) do
		local formspec = "background[0.06,0.99;7.92,7.52;ui_misc_form.png]"
		local y = -0.1
		for i, skin in ipairs(arr) do
			local x = (i - 1) % 8
			if i > 1 and x == 0 then
				y = 1.8
			end
			formspec = (formspec.."image_button["..x..","..y..";1,2;"..
				skin[2].."_preview.png;u_skins_set$"..skin[1]..";]"..
				"tooltip[u_skins_set$"..skin[1]..";"..u_skins.meta[skin[2]].name.."]")
		end
		local page_prev = page - 2
		local page_next = page
		if page_prev < 0 then
			page_prev = total_pages - 1
		end
		if page_next >= total_pages then
			page_next = 0
		end
		formspec = (formspec
			.."button[0,3.8;1,.5;u_skins_page$"..page_prev..";<<]"
			.."button[.75,3.8;6.5,.5;u_skins_null;Page "..page.."/"..total_pages.."]"
			.."button[7,3.8;1,.5;u_skins_page$"..page_next..";>>]")
		
		unified_inventory.register_page("u_skins_page$"..(page - 1), {
			get_formspec = function(player)
				return {formspec=formspec}
			end
		})
	end
end

-- click button handlers
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.u_skins then
		unified_inventory.set_inventory_formspec(player, "craft")
		return
	end
	for field, _ in pairs(fields) do
		local current = string.split(field, "$", 2)
		if current[1] == "u_skins_set" then
			u_skins.u_skins[player:get_player_name()] = u_skins.list[tonumber(current[2])]
			u_skins.update_player_skin(player)
			u_skins.file_save = true
			unified_inventory.set_inventory_formspec(player, "u_skins")
		elseif current[1] == "u_skins_page" then
			u_skins.pages[player:get_player_name()] = current[2]
			unified_inventory.set_inventory_formspec(player, "u_skins_page$"..current[2])
		end
	end
end)

-- Change skin on join - reset if invalid
minetest.register_on_joinplayer(function(player)
	local player_name = player:get_player_name()
	if not u_skins.is_skin(u_skins.u_skins[player_name]) then
		u_skins.u_skins[player_name] = u_skins.default
	end
	u_skins.update_player_skin(player)
end)

u_skins.generate_pages()
u_skins.load_players()