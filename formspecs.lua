local S = skins.S

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
