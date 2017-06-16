skins.list = {}

local skins_dir_list = minetest.get_dir_list(skins.modpath.."/textures")
local unsorted_skinslist = {}
for _, fn in pairs(skins_dir_list) do
	if fn:find("^character_") then
		nameparts = string.gsub(fn, "[.]", "_"):split("_")
		local id = nameparts[2]
		local name = "character_"..id
		local skin_obj = skins.get(name) or skins.new(name)
		if nameparts[3] == "preview" then
			skin_obj:set_preview(fn)
		else
			local file = io.open(skins.modpath.."/meta/"..name..".txt", "r")
			if file then
				local data = string.split(file:read("*all"), "\n", 3)
				file:close()
				skin_obj:set_texture(fn)
				skin_obj:set_meta("_sort_id", tonumber(id))
				skin_obj:set_meta("name", data[1])
				skin_obj:set_meta("author", data[2])
				skin_obj:set_meta("license", data[3])
			end
			table.insert(unsorted_skinslist, skin_obj)
		end
	end
end

table.sort(unsorted_skinslist, function(a,b) return a:get_meta("_sort_id") < b:get_meta("_sort_id") end)
for _,v in ipairs(unsorted_skinslist) do
	table.insert(skins.list, v)
end
