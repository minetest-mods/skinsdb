local S
if minetest.get_modpath("intllib") then
	S = intllib.Getter()
else
	S = function(s) return s end
end

local dropdown_values = {}
local skins_reftab = {}
local skins_reftab_byskin = {}

unified_inventory.register_page("skins", {
	get_formspec = function(player)
		local name = player:get_player_name()
		local skin = skins.get_player_skin(player)
		local formspec = ("background[0.06,0.99;7.92,7.52;ui_misc_form.png]"
			.."image[0,.75;1,2;"..skins.preview[skin].."]"
			.."label[6,.5;"..S("Raw texture")..":]"
			.."image[6,1;2,1;"..skins.list[skin].."]")

		local meta = skins.meta[skin]
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
		local page = 1
		if skins_reftab_byskin[skin] then
			page = skins_reftab_byskin[skin].page
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
skins.generate_pages = function()
	local total_pages = 1

	local i = 0
	for skin, _ in pairs(skins.list) do
		local page = math.floor(i / 16)+1
		local index_p = i%16+1
		i = i + 1
		skins_reftab[i] = { index = i, page = page, index_p = index_p, skin = skin }
		skins_reftab_byskin[skin] = skins_reftab[i]
		total_pages = page
	end

	for page=1, total_pages do
		local formspec = "background[0.06,0.99;7.92,7.52;ui_misc_form.png]"
print(dump(skins_reftab[i]))
		for i = (page-1)*16+1, page*16+1 do
			print("print", i)
			if not skins_reftab[i] then
				break
			end
			local index_p = skins_reftab[i].index_p
			local x = index_p % 8
			local y
			if index_p >= 8 then
				y = 1.8
			else
				y = -0.1
			end
			formspec = (formspec.."image_button["..x..","..y..";1,2;"..
				skins.preview[skins_reftab[i].skin]..";skins_set$"..i..";]"..
				"tooltip[skins_set$"..i..";"..skins.meta[skins_reftab[i].skin].name.."]")
		end
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
			.."dropdown[1,3.65;6.5,.5;skins_selpg;"..page_list..";"..page.."]"
			.."button[7,3.8;1,.5;skins_page$"..page_next..";>>]")
	print("register page", page, formspec)
		unified_inventory.register_page("skins_page$"..(page), {
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
	print(field, current[1], current[2])
		if current[1] == "skins_set" then
			skins.set_player_skin(player, skins.list[skins_reftab[current[2]]])
			unified_inventory.set_inventory_formspec(player, "skins")
			return
		elseif current[1] == "skins_page" then
			unified_inventory.set_inventory_formspec(player, "skins_page$"..current[2])
			return
		end
	end
	if fields.skins_selpg then
		page = dropdown_values[fields.skins_selpg]
		unified_inventory.set_inventory_formspec(player, "skins_page$"..(page))
		return
	end
end)

skins.generate_pages()
