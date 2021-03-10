local S = minetest.get_translator("skinsdb")
local ui = unified_inventory

function skins.get_formspec_context(player)
	if player then
		local playername = player:get_player_name()
		skins.ui_context[playername] = skins.ui_context[playername] or {}
		return skins.ui_context[playername]
	else
		return {}
	end
end

-- Show skin info
function skins.get_skin_info_formspec(skin, perplayer_formspec)
	local texture = skin:get_texture()
	local m_name = skin:get_meta_string("name")
	local m_author = skin:get_meta_string("author")
	local m_license = skin:get_meta_string("license")
	local m_format = skin:get_meta("format")
	-- overview page
	local raw_size = m_format == "1.8" and "2,2" or "2,1"

	local lxoffs = 0.8
	local cxoffs = 2
	local rxoffs = 5.5

	if type(perplayer_formspec) == "table" then -- we're using Unified Inventory
		lxoffs = 1.5
		cxoffs = 3.75
		rxoffs = 7.5
	end

	local formspec = "image["..lxoffs..",.6;1,2;"..minetest.formspec_escape(skin:get_preview()).."]"
	if texture then
		formspec = formspec.."label["..rxoffs..",.5;"..S("Raw texture")..":]"
		.."image["..rxoffs..",1;"..raw_size..";"..texture.."]"
	end
	if m_name ~= "" then
		formspec = formspec.."label["..cxoffs..",.5;"..S("Name")..": "..minetest.formspec_escape(m_name).."]"
	end
	if m_author ~= "" then
		formspec = formspec.."label["..cxoffs..",1;"..S("Author")..": "..minetest.formspec_escape(m_author).."]"
	end
	if m_license ~= "" then
		formspec = formspec.."label["..cxoffs..",1.5;"..S("License")..": "..minetest.formspec_escape(m_license).."]"
	end
	return formspec
end

function skins.get_skin_selection_formspec(player, context, perplayer_formspec)
	context.skins_list = skins.get_skinlist_for_player(player:get_player_name())
	context.total_pages = 1
	local xoffs = 0
	local yoffs = 4
	local xspc = 1
	local yspc = 2
	local skinwidth = 1
	local skinheight = 2
	local xscale = 1
	local btn_y = 8.15
	local drop_y = 8
	local btn_width = 1
	local droppos = 1
	local droplen = 6.25
	local btn_right = 7
	local maxdisp = 16

	local ctrls_height = 0.5

	if type(perplayer_formspec) == "table" then -- it's being used under Unified Inventory
		xoffs =  perplayer_formspec.std_inv_x
		xspc =   ui.imgscale
		yspc =   ui.imgscale*2
		skinwidth =  ui.imgscale*0.9
		skinheight = ui.imgscale*1.9
		xscale = ui.imgscale
		btn_width = ui.imgscale
		droppos = xoffs + btn_width + 0.1
		droplen = ui.imgscale * 6 - 0.2
		btn_right = droppos + droplen + 0.1

		if perplayer_formspec.pagecols == 4 then -- and we're in lite mode
			yoffs =  1
			maxdisp = 8
			drop_y = yoffs + skinheight + 0.1
		else
			yoffs =  0.2
			drop_y = yoffs + skinheight*2 + 0.2
		end

		btn_y = drop_y

	end

	for i, skin in ipairs(context.skins_list ) do
		local page = math.floor((i-1) / maxdisp)+1
		skin:set_meta("inv_page", page)
		skin:set_meta("inv_page_index", (i-1)%maxdisp+1)
		context.total_pages = page
	end
	context.skins_page = context.skins_page or skins.get_player_skin(player):get_meta("inv_page") or 1
	context.dropdown_values = nil

	local page = context.skins_page
	local formspec = ""
	
	for i = (page-1)*maxdisp+1, page*maxdisp do
		local skin = context.skins_list[i]
		if not skin then
			break
		end

		local index_p = skin:get_meta("inv_page_index")
		local x = ((index_p-1) % 8) * xspc + xoffs
		local y
		if index_p > 8 then
			y = yoffs + yspc
		else
			y = yoffs
		end
		formspec = formspec..
			string.format("image_button[%f,%f;%f,%f;%s;skins_set$%i;]",
				x, y, skinwidth, skinheight,
				minetest.formspec_escape(skin:get_preview()), i)..
			"tooltip[skins_set$"..i..";"..minetest.formspec_escape(skin:get_meta_string("name")).."]"
	end

	if context.total_pages > 1 then
		local page_prev = page - 1
		local page_next = page + 1
		if page_prev < 1 then
			page_prev = context.total_pages
		end
		if page_next > context.total_pages then
			page_next = 1
		end
		local page_list = ""
		context.dropdown_values = {}
		for pg=1, context.total_pages do
			local pagename = S("Page").." "..pg.."/"..context.total_pages
			context.dropdown_values[pagename] = pg
			if pg > 1 then page_list = page_list.."," end
			page_list = page_list..pagename
		end
		formspec = formspec..
			string.format("button[%f,%f;%f,%f;skins_page$%i;<<]",
				xoffs, btn_y, btn_width, ctrls_height, page_prev)..
			string.format("button[%f,%f;%f,%f;skins_page$%i;>>]",
				btn_right, btn_y, btn_width, ctrls_height, page_next)..
			string.format("dropdown[%f,%f;%f,%f;skins_selpg;%s;%i]",
				droppos, drop_y, droplen, ctrls_height, page_list, page)
	end
	return formspec
end

function skins.on_skin_selection_receive_fields(player, context, fields)
	for field, _ in pairs(fields) do
		local current = string.split(field, "$", 2)
		if current[1] == "skins_set" then
			skins.set_player_skin(player, context.skins_list[tonumber(current[2])])
			return 'set'
		elseif current[1] == "skins_page" then
			context.skins_page = tonumber(current[2])
			return 'page'
		end
	end
	if fields.skins_selpg then
		context.skins_page = tonumber(context.dropdown_values[fields.skins_selpg])
		return 'page'
	end
end
