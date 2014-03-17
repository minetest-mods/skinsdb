-- Unified Skins for Minetest - based modified Bags from unfied_inventory and skins from inventory_plus

-- Copyright (c) 2012 cornernote, Dean Montgomery
-- License: GPLv3
u_skins = {}
u_skins.type = { SPRITE=0, MODEL=1 }
u_skins.pages = {}
u_skins.u_skins = {}

u_skins.get_type = function(texture)
	if not texture then return end
	if string.sub(texture,0,string.len("character")) == "character" then
		return u_skins.type.MODEL
	end
	if string.sub(texture,0,string.len("player")) == "player" then
		return u_skins.type.SPRITE
	end
end

u_skins.modpath = minetest.get_modpath("u_skins")
dofile(u_skins.modpath.."/skinlist.lua")
dofile(u_skins.modpath.."/meta.lua")
dofile(u_skins.modpath.."/players.lua")


u_skins.update_player_skin = function(player)
	name = player:get_player_name()
	if u_skins.get_type(u_skins.u_skins[name]) == u_skins.type.SPRITE then
		player:set_properties({
			visual = "upright_sprite",
			textures = {u_skins.u_skins[name]..".png",u_skins.u_skins[name].."_back.png"},
			visual_size = {x=1, y=2},
		})
	elseif u_skins.get_type(u_skins.u_skins[name]) == u_skins.type.MODEL then
		player:set_properties({
			visual = "mesh",
			textures = {u_skins.u_skins[name]..".png"},
			visual_size = {x=1, y=1},
		})
	end
	u_skins.save()
end

-- Display Current Skin
unified_inventory.register_page("u_skins", {
	get_formspec = function(player)
		name = player:get_player_name()
		local formspec = "background[0.06,0.99;7.92,7.52;ui_misc_form.png]"
		if u_skins.get_type(u_skins.u_skins[name]) == u_skins.type.MODEL then
			formspec = formspec
				.. "image[0,.75;1,2;"..u_skins.u_skins[name].."_preview.png]"
				.. "image[1,.75;1,2;"..u_skins.u_skins[name].."_preview_back.png]"
				.. "label[6,.5;Raw texture:]"
				.. "image[6,1;2,1;"..u_skins.u_skins[name]..".png]"
			
		else
			formspec = formspec
				.. "image[0,.75;1,2;"..u_skins.u_skins[name]..".png]"
				.. "image[1,.75;1,2;"..u_skins.u_skins[name].."_back.png]"
		end
		local meta = u_skins.meta[u_skins.u_skins[name]]
		if meta then
			if meta.name then
				formspec = formspec .. "label[2,.5;Name: "..meta.name.."]"
			end
			if meta.author then
				formspec = formspec .. "label[2,1;Author: "..meta.author.."]"
			end
			if meta.description then
				formspec = formspec .. "label[2,1.5;"..meta.description.."]"
			end
			if meta.comment then
				formspec = formspec .. 'label[2,2;"'..meta.comment..'"]'
			end
		end

		formspec = formspec .. "button[.75,3;6.5,.5;u_skins_page_0;Change]"
		return {formspec=formspec}
	end,
})

unified_inventory.register_button("u_skins", {
	type = "image",
	image = "u_skins_button.png",
})

-- Create all of the skin-picker pages.
for x = 0, math.floor(#u_skins.list/16+1) do
	unified_inventory.register_page("u_skins_page_"..x, {
		get_formspec = function(player)
			page = u_skins.pages[player:get_player_name()]
			if page == nil then page = 0 end
			local formspec = "background[0.06,0.99;7.92,7.52;ui_misc_form.png]"
			local index = 0
			local skip = 0 -- Skip u_skins, used for pages
			-- skin thumbnails
			for i, skin in ipairs(u_skins.list) do
				if skip < page*16 then skip = skip + 1 else
					if index < 16 then
						formspec = formspec .. "image_button["..(index%8)..","..((math.floor(index/8))*2)..";1,2;"..skin
						if u_skins.get_type(skin) == u_skins.type.MODEL then
							formspec = formspec .. "_preview"
						end
						formspec = formspec .. ".png;u_skins_set_"..i..";]"
					end
					index = index +1
				end
			end
			-- prev next page buttons
			if page > 0 then
				formspec = formspec .. "button[0,4;1,.5;u_skins_page_"..(page-1)..";<<]"
			else
				formspec = formspec .. "button[0,4;1,.5;u_skins_page_"..page..";<<]"
			end
			formspec = formspec .. "button[.75,4;6.5,.5;u_skins_page_"..page..";Page "..(page+1).."/"..math.floor(#u_skins.list/16+1).."]" -- a button is used so text is centered
			if index > 16 then
				formspec = formspec .. "button[7,4;1,.5;u_skins_page_"..(page+1)..";>>]"
			else
				formspec = formspec .. "button[7,4;1,.5;u_skins_page_"..page..";>>]"
			end
			return {formspec=formspec}
		end,
	})
end

-- click button handlers
minetest.register_on_player_receive_fields(function(player,formname,fields)
	if fields.u_skins then
		unified_inventory.set_inventory_formspec(player,"craft")
	end
	for field, _ in pairs(fields) do
		if string.sub(field,0,string.len("u_skins_set_")) == "u_skins_set_" then
			u_skins.u_skins[player:get_player_name()] = u_skins.list[tonumber(string.sub(field,string.len("u_skins_set_")+1))]
			u_skins.update_player_skin(player)
			unified_inventory.set_inventory_formspec(player,"u_skins")
		end
		if string.sub(field,0,string.len("u_skins_page_")) == "u_skins_page_" then
			u_skins.pages[player:get_player_name()] = tonumber(string.sub(field,string.len("u_skins_page_")+1))
			unified_inventory.set_inventory_formspec(player,"u_skins_page_"..u_skins.pages[player:get_player_name()])
		end
	end
end)

-- set defaults
minetest.register_on_joinplayer(function(player)
	if not u_skins.u_skins[player:get_player_name()] then
		u_skins.u_skins[player:get_player_name()] = "character_1"
	end
	u_skins.update_player_skin(player)
end)

