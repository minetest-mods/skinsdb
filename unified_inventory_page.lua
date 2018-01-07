local S
if minetest.get_modpath("intllib") then
	S = intllib.Getter()
else
	S = function(s) return s end
end

local dropdown_values = {}
local skins_reftab = {}
local skins_list = skins.get_skinlist_for_player() --public only
unified_inventory.register_page("skins", {
	get_formspec = function(player)
		local name = player:get_player_name()
		local skin = skins.get_player_skin(player)
		local texture = skin:get_texture()
		local m_name = skin:get_meta_string("name")
		local m_author = skin:get_meta_string("author")
		local m_license = skin:get_meta_string("license")
		local formspec = "background[0.06,0.99;7.92,7.52;ui_misc_form.png]".."image[0,.75;1,2;"..skin:get_preview().."]"
		if texture then
			formspec=formspec.."label[6,.5;"..S("Raw texture")..":]"
			.."image[6,1;2,1;"..texture.."]"
		end
		if m_name ~= "" then
			formspec = formspec.."label[2,.5;"..S("Name")..": "..minetest.formspec_escape(m_name).."]"
		end
		if m_author ~= "" then
			formspec = formspec.."label[2,1;"..S("Author")..": "..minetest.formspec_escape(m_author).."]"
		end
		if m_license ~= "" then
			formspec = formspec.."label[2,1.5;"..S("License")..": "..minetest.formspec_escape(m_license).."]"
		end

		local page = skin:get_meta("inv_page") or 1
		formspec = formspec .. "button[.75,3;6.5,.5;skins_page$"..page..";"..S("Change").."]"
		return {formspec=formspec}
	end,
})

unified_inventory.register_button("skins", {
	type = "image",
	image = "skins_button.png",
})

-- Create all of the skin-picker pages.
local total_pages = 1
for i, skin in ipairs(skins_list) do
	local page = math.floor((i-1) / 16)+1
	skin:set_meta("inv_page", page)
	skin:set_meta("inv_page_index", (i-1)%16+1)
	total_pages = page
end

for page=1, total_pages do
	local formspec = "background[0.06,0.99;7.92,7.52;ui_misc_form.png]"
	for i = (page-1)*16+1, page*16 do
		local skin = skins_list[i]
		if not skin then
			break
		end

		local index_p = skin:get_meta("inv_page_index")
		local x = (index_p-1) % 8
		local y
		if index_p > 8 then
			y = 1.8
		else
			y = -0.1
		end
		formspec = (formspec.."image_button["..x..","..y..";1,2;"..
			skin:get_preview()..";skins_set$"..i..";]"..
			"tooltip[skins_set$"..i..";"..minetest.formspec_escape(skin:get_meta_string("name")).."]")
	end
	if total_pages > 1 then
		local page_prev = page - 1
		local page_next = page + 1
		if page_prev < 1 then
			page_prev = total_pages
		end
		if page_next > total_pages then
			page_next = 1
		end
		local page_list = ""
		dropdown_values = {}
		for pg=1, total_pages do
			local pagename = S("Page").." "..pg.."/"..total_pages
			dropdown_values[pagename] = pg
			if pg > 1 then page_list = page_list.."," end
			page_list = page_list..pagename
		end
		formspec = (formspec
			.."button[0,3.8;1,.5;skins_page$"..page_prev..";<<]"
			.."dropdown[1,3.68;6.5,.5;skins_selpg;"..page_list..";"..page.."]"
			.."button[7,3.8;1,.5;skins_page$"..page_next..";>>]")
	end
	unified_inventory.register_page("skins_page$"..(page), {
		get_formspec = function(player)
			return {formspec=formspec}
		end
	})
end


-- click button handlers
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.skins then
		unified_inventory.set_inventory_formspec(player, "craft")
		return
	end
	for field, _ in pairs(fields) do
		local current = string.split(field, "$", 2)
		if current[1] == "skins_set" then
			skins.set_player_skin(player, skins_list[tonumber(current[2])])
			unified_inventory.set_inventory_formspec(player, "skins")
			return
		elseif current[1] == "skins_page" then
			unified_inventory.set_inventory_formspec(player, "skins_page$"..current[2])
			return
		end
	end
	if fields.skins_selpg then
		local page = dropdown_values[fields.skins_selpg]
		unified_inventory.set_inventory_formspec(player, "skins_page$"..(page))
		return
	end
end)
