u_skins.file = minetest.get_worldpath() .. "/u_skins.mt"
u_skins.load = function()
	local input = io.open(u_skins.file, "r")
	local data = nil
	if input then
		data = input:read('*all')
	end
	if data and data ~= "" then
		lines = string.split(data,"\n")
		for _, line in ipairs(lines) do
			data = string.split(line, ' ', 2)
			u_skins.u_skins[data[1]] = data[2]
		end
		io.close(input)
	end
end
u_skins.load()

u_skins.save = function()
	local output = io.open(u_skins.file,'w')
	for name, skin in pairs(u_skins.u_skins) do
		if name and skin then
			output:write(name .. " " .. skin .. "\n")
		end
	end
	io.close(output)
end

