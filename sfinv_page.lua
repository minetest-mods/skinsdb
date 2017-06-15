local S
if minetest.get_modpath("intllib") then
	S = intllib.Getter()
else
	S = function(s) return s end
end

local dropdown_values = {}
local skins_reftab = {}
local skins_reftab_byskin = {}

-- collect skins data
local total_pages = 1
for i, skin in ipairs(skins.list) do
	local page = math.floor((i-1) / 16)+1
	local index_p = (i-1)%16+1
	skins_reftab[i] = { index = i, page = page, index_p = index_p, skin = skin }
	skins_reftab_byskin[skin] = skins_reftab[i]
	total_pages = page
end

-- generate the current formspec
local function get_formspec(player, context)
	local name = player:get_player_name()
	local skin = skins.get_player_skin(player)

	-- overview page
	local formspec = "image[0,.75;1,2;"..skins.preview[skin].."]"
		.."label[6,.5;"..S("Raw texture")..":]"
		.."image[6,1;2,1;"..skins.textures[skin].."]"

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
	if context.skins_page then
		page = context.skins_page 
	elseif skins_reftab_byskin[skin] then
		page = skins_reftab_byskin[skin].page
	end

	for i = (page-1)*16+1, page*16 do
		if not skins_reftab[i] then
			break
		end
		local index_p = skins_reftab[i].index_p
		local x = (index_p-1) % 8
		local y
		if index_p > 8 then
			y = 5.5
		else
			y = 3.2
		end
		formspec = formspec.."image_button["..x..","..y..";1,2;"..
			skins.preview[skins_reftab[i].skin]..";skins_set$"..i..";]"..
			"tooltip[skins_set$"..i..";"..minetest.formspec_escape(skins.meta[skins_reftab[i].skin].name).."]"
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
				skins.set_player_skin(player, skins_reftab[tonumber(current[2])].skin)
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
