local S
if minetest.get_modpath("intllib") then
	S = intllib.Getter()
else
	S = function(s) return s end
end

unified_inventory.register_page("skins", {
	get_formspec = function(player)
		local name = player:get_player_name()
		if not skins.is_skin(skins.skins[name]) then
			skins.skins[name] = skins.default
		end

		local formspec = ("background[0.06,0.99;7.92,7.52;ui_misc_form.png]"
			.."image[0,.75;1,2;"..skins.skins[name].."_preview.png]"
			.."label[6,.5;"..S("Raw texture")..":]"
			.."image[6,1;2,1;"..skins.skins[name]..".png]")

		local meta = skins.meta[skins.skins[name]]
		if meta then
			if meta.name ~= "" then
				formspec = formspec.."label[2,.5;"..S("Name")..": "..minetest.formspec_escape(meta.name).."]"
			end
			if meta.author ~= "" then
				formspec = formspec.."label[2,1;"..S("Author")..": "..minetest.formspec_escape(meta.author).."]"
			end
			if meta.license ~= "" then
				formspec = formspec.."label[2,1.5;"..S("License")..": "..minetest.formspec_escape(meta.license).."]"
			end
			if meta.description ~= "" then --what's that??
				formspec = formspec.."label[2,2;"..S("Description")..": "..minetest.formspec_escape(meta.description).."]"
			end
		end
		local page = 0
		if skins.pages[name] then
			page = skins.pages[name]
		end
		formspec = formspec .. "button[.75,3;6.5,.5;skins_page$"..page..";"..S("Change").."]"
		return {formspec=formspec}
	end,
})

unified_inventory.register_button("skins", {
	type = "image",
	image = "skins_button.png",
})

-- Create all of the skin-picker pages.


local dropdown_values = {}

skins.generate_pages = function(texture)
	local page = 0
	local pages = {}
	for i, skin in ipairs(skins.list) do
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
				skin[2].."_preview.png;skins_set$"..skin[1]..";]"..
				"tooltip[skins_set$"..skin[1]..";"..skins.meta[skin[2]].name.."]")
		end
		local page_prev = page - 2
		local page_next = page
		if page_prev < 0 then
			page_prev = total_pages - 1
		end
		if page_next >= total_pages then
			page_next = 0
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
			.."dropdown[1,3.65;6.5,.5;skins_selpg;"..page_list..";"..page.."]"
			.."button[7,3.8;1,.5;skins_page$"..page_next..";>>]")
		
		unified_inventory.register_page("skins_page$"..(page - 1), {
			get_formspec = function(player)
				return {formspec=formspec}
			end
		})
	end
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
			skins.skins[player:get_player_name()] = skins.list[tonumber(current[2])]
			skins.update_player_skin(player)
			skins.file_save = true
			unified_inventory.set_inventory_formspec(player, "skins")
			return
		elseif current[1] == "skins_page" then
			skins.pages[player:get_player_name()] = current[2]
			unified_inventory.set_inventory_formspec(player, "skins_page$"..current[2])
			return
		end
	end
	if fields.skins_selpg then
		page = dropdown_values[fields.skins_selpg]
		skins.pages[player:get_player_name()] = page
		unified_inventory.set_inventory_formspec(player, "skins_page$"..(page-1))
		return
	end
end)

skins.generate_pages()
skins.load_players()
