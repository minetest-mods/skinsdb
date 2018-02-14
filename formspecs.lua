local S = skins.S


-- Prepare server-site state / context
function skins.rebuild_formspec_context(player, context)
	local skin = skins.get_player_skin(player)
	context.skins_list = skins.get_skinlist_for_player(player:get_player_name())
	context.total_pages = 1
	for i, skin in ipairs(context.skins_list ) do
		local page = math.floor((i-1) / 16)+1
		skin:set_meta("inv_page", page)
		skin:set_meta("inv_page_index", (i-1)%16+1)
		context.total_pages = page
	end
	context.skins_page = context.skins_page or skin:get_meta("inv_page")
	context.dropdown_values = nil
	return context
end


-- Show skin info
function skins.get_skin_info_formspec(skin)
	local texture = skin:get_texture()
	local m_name = skin:get_meta_string("name")
	local m_author = skin:get_meta_string("author")
	local m_license = skin:get_meta_string("license")
	-- overview page
	local formspec = "image[0,.75;1,2;"..skin:get_preview().."]"
	if texture then
		formspec = formspec.."label[6,.5;"..S("Raw texture")..":]"
		.."image[6,1;2,1;"..skin:get_texture().."]"
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
	return formspec
end

function skins.get_skin_selection_formspec(player, context, y_delta)
	skins.rebuild_formspec_context(player, context)
	local page = context.skins_page or 1
	local formspec = ""
	for i = (page-1)*16+1, page*16 do
		local skin = context.skins_list[i]
		if not skin then
			break
		end

		local index_p = skin:get_meta("inv_page_index")
		local x = (index_p-1) % 8
		local y
		if index_p > 8 then
			y = y_delta + 1.9
		else
			y = y_delta
		end
		formspec = formspec.."image_button["..x..","..y..";1,2;"..
			skin:get_preview()..";skins_set$"..i..";]"..
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
		formspec = formspec
			.."button[0,"..(y_delta+4.0)..";1,.5;skins_page$"..page_prev..";<<]"
			.."dropdown[0.9,"..(y_delta+3.88)..";6.5,.5;skins_selpg;"..page_list..";"..page.."]"
			.."button[7,"..(y_delta+4.0)..";1,.5;skins_page$"..page_next..";>>]"
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
