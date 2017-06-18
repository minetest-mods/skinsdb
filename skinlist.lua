
local skins_dir_list = minetest.get_dir_list(skins.modpath.."/textures")
local unsorted_skinslist = {}
local sorted_skinslist
for _, fn in pairs(skins_dir_list) do
	local nameparts = string.gsub(fn, "[.]", "_"):split("_")

	local name, sort_id, assignment, is_preview
	if nameparts[1] == "character" then
		sort_id = tonumber(nameparts[2])+5000
		name = "character_"..nameparts[2]
		is_preview = (nameparts[3] == "preview")
	elseif nameparts[1] == "player" then
		assignment = "player:"..nameparts[2]
		name = "player_"..nameparts[2]
		if tonumber(nameparts[3]) then
			sort_id = tonumber(nameparts[3])
			is_preview = (nameparts[4] == "preview")
			name = name.."_"..nameparts[3]
		else
			sort_id = 1
			is_preview = (nameparts[3] == "preview")
		end
	end

	if name then
		local skin_obj = skins.get(name) or skins.new(name)
		if is_preview then
			skin_obj:set_preview(fn)
		else
			skin_obj:set_texture(fn)
			skin_obj:set_meta("_sort_id", sort_id)
			if assignment then
				skin_obj:set_meta("assignment", assignment)
			end
			local file = io.open(skins.modpath.."/meta/"..name..".txt", "r")
			if file then
				local data = string.split(file:read("*all"), "\n", 3)
				file:close()
				skin_obj:set_meta("name", data[1])
				skin_obj:set_meta("author", data[2])
				skin_obj:set_meta("license", data[3])
			else
				skin_obj:set_meta("name", name)
			end
			table.insert(unsorted_skinslist, skin_obj)
		end
	end
end

-- get skinlist. If assignment given ("mod:wardrobe" or "player:bell07") select skins matches the assignment. select_unassigned selects the skins without any assignment too
function skins.get_skinlist(assignment, select_unassigned)
	-- sort on demand
	if not sorted_skinslist then
		table.sort(unsorted_skinslist, function(a,b) return a:get_meta("_sort_id") < b:get_meta("_sort_id") end)
		sorted_skinslist = unsorted_skinslist
	end
	if not assignment then
		return sorted_skinslist
	else
		local ret = {}
		for _, skin in ipairs(sorted_skinslist) do
			if assignment == skin:get_meta("assignment") or
					(select_unassigned and skin:get_meta("assignment") == nil) then
				table.insert(ret, skin)
			end
		end
		return ret
	end
end
