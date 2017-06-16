local S
if minetest.get_modpath("intllib") then
	S = intllib.Getter()
else
	S = function(s) return s end
end

local dropdown_values = {}
--local skins_reftab = {} --skins.list

-- collect skins data
local total_pages = 1
for i, skin in ipairs(skins.list) do
	skin:set_meta("inv_page", math.floor((i-1) / 16)+1)
	skin:set_meta("inv_page_index", (i-1)%16+1)
	total_pages = page
end

-- generate the current formspec
local function get_formspec(player, context)
	local name = player:get_player_name()
	local skin = skins.get_player_skin(player)

	-- overview page
	local formspec = "image[0,.75;1,2;"..skin:get_preview().."]"
		.."label[6,.5;"..S("Raw texture")..":]"
		.."image[6,1;2,1;"..skin:get_texture().."]"

	local m_name = skin:get_meta_string("name")
	local m_author = skin:get_meta_string("author")
	local m_license = skin:get_meta_string("license")
	if m_name ~= "" then
		formspec = formspec.."label[2,.5;"..S("Name")..": "..minetest.formspec_escape(m_name).."]"
	end
	if m_author ~= "" then
		formspec = formspec.."label[2,1;"..S("Author")..": "..minetest.formspec_escape(m_author).."]"
	end
	if m_license ~= "" then
		formspec = formspec.."label[2,1.5;"..S("License")..": "..minetest.formspec_escape(m_license).."]"
	end

	local page = 1
	if context.skins_page then
		page = context.skins_page 
	else
		page = skin:get_meta("inv_page") or 1
	end

	for i = (page-1)*16+1, page*16 do
		local skin = skins.list[i]
		if not skin then
			break
		end

		local index_p = skin:get_meta("inv_page_index")
		local x = (index_p-1) % 8
		local y
		if index_p > 8 then
			y = 5.5
		else
			y = 3.2
		end
		formspec = formspec.."image_button["..x..","..y..";1,2;"..
			skin:get_preview()..";skins_set$"..i..";]"..
			"tooltip[skins_set$"..i..";"..minetest.formspec_escape(skin:get_meta_string("name")).."]"
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
	formspec = formspec
		.."button[0,8.3;1,.5;skins_page$"..page_prev..";<<]"
		.."dropdown[1,8.16;6.5,.5;skins_selpg;"..page_list..";"..page.."]"
		.."button[7,8.3;1,.5;skins_page$"..page_next..";>>]"

	return formspec
end

sfinv.register_page("skins:overview", {
	title = "Skins",
	get = function(self, player, context)
		return sfinv.make_formspec(player, context, get_formspec(player, context))
	end,
	on_player_receive_fields = function(self, player, context, fields)
		for field, _ in pairs(fields) do
			local current = string.split(field, "$", 2)
			if current[1] == "skins_set" then
				skins.set_player_skin(player, skins.list[tonumber(current[2])])
				sfinv.set_player_inventory_formspec(player)
				return
			elseif current[1] == "skins_page" then
				context.skins_page = tonumber(current[2])
				sfinv.set_player_inventory_formspec(player)
				return
			end
		end
		if fields.skins_selpg then
			context.skins_page = tonumber(dropdown_values[fields.skins_selpg])
			sfinv.set_player_inventory_formspec(player)
			return
		end
	end
})
