skins.list = {}
skins.meta = {}
skins.preview = {}

local skins_dir_list = minetest.get_dir_list(skins.modpath.."/textures")
for _, fn in pairs(skins_dir_list) do
	if fn:find("^character_") then
		nameparts = string.gsub(fn, "[.]", "_"):split("_")
		local id = nameparts[2]
		local name = "character_"..id
		if nameparts[3] == "preview" then
			skins.preview[name] = fn
		else
			local file = io.open(skins.modpath.."/meta/"..name..".txt", "r")
			if file then
				local data = string.split(file:read("*all"), "\n", 3)
				file:close()
				skins.list[name] = fn
				skins.meta[name] = {}
				skins.meta[name].name = data[1]
				skins.meta[name].author = data[2]
				skins.meta[name].license = data[3]
				skins.meta[name].description = "" --what's that??
			end
		end
	end
end

