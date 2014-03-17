u_skins.meta = {}
for _, i in ipairs(u_skins.list) do
	u_skins.meta[i] = {}
	local f = io.open(u_skins.modpath.."/meta/"..i..".txt")
	local data = nil
	if f then
		data = minetest.deserialize("return {"..f:read('*all').."}")
		f:close()
	end
	data = data or {}
	u_skins.meta[i].name = data.name or ""
	u_skins.meta[i].author = data.author or ""
	u_skins.meta[i].description = data.description or nil
	u_skins.meta[i].comment = data.comment or nil
end
