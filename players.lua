skins.load_players = function()
	local file = io.open(skins.file, "r")
	if file then
		for line in file:lines() do
			local data = string.split(line, " ", 2)
			skins.skins[data[1]] = data[2]
		end
		io.close(file)
	end
end
skins.load_players()

local ttime = 0
minetest.register_globalstep(function(t)
	ttime = ttime + t
	if ttime < 360 then --every 6min'
		return
	end
	ttime = 0
	skins.save()
end)

minetest.register_on_shutdown(function() skins.save() end)

skins.save = function()
	if not skins.file_save then
		return
	end
	skins.file_save = false
	local output = io.open(skins.file, "w")
	for name, skin in pairs(skins.skins) do
		if name and skin then
			if skin ~= skins.default then
				output:write(name.." "..skin.."\n")
			end
		end
	end
	io.close(output)
end

