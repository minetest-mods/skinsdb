u_skins.load_players = function()
	local file = io.open(u_skins.file, "r")
	if file then
		for line in file:lines() do
			local data = string.split(line, " ", 2)
			u_skins.u_skins[data[1]] = data[2]
		end
		io.close(file)
	end
end
u_skins.load_players()

local ttime = 0
minetest.register_globalstep(function(t)
	ttime = ttime + t
	if ttime < 360 then --every 6min'
		return
	end
	ttime = 0
	u_skins.save()
end)

minetest.register_on_shutdown(function() u_skins.save() end)

u_skins.save = function()
	if not u_skins.file_save then
		return
	end
	u_skins.file_save = false
	local output = io.open(u_skins.file, "w")
	for name, skin in pairs(u_skins.u_skins) do
		if name and skin then
			if skin ~= u_skins.default then
				output:write(name.." "..skin.."\n")
			end
		end
	end
	io.close(output)
end

