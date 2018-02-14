local S = skins.S

unified_inventory.register_page("skins", {
	get_formspec = function(player)
		local skin = skins.get_player_skin(player)
		local formspec = "background[0.06,0.99;7.92,7.52;ui_misc_form.png]"..skins.get_skin_info_formspec(skin)..
				"button[.75,3;6.5,.5;skins_page;"..S("Change").."]"
		return {formspec=formspec}
	end,
})

unified_inventory.register_button("skins", {
	type = "image",
	image = "skins_button.png",
})

local function get_formspec(player)
	-- unified inventory is stateless, but skins pager needs some context usage to be more flexible
	local context = minetest.deserialize(player:get_attribute('skinsdb_unified_inventory_context')) or {}
	context = skins.rebuild_formspec_context(player, context)
	local formspec = "background[0.06,0.99;7.92,7.52;ui_misc_form.png]"..
			skins.get_skin_selection_formspec(context, -0.2)
	player:set_attribute('skinsdb_unified_inventory_context', minetest.serialize(context))
	return formspec
end

unified_inventory.register_page("skins_page", {
	get_formspec = function(player)
		return {formspec=get_formspec(player)}
	end
})

-- click button handlers
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.skins then
		player:set_attribute('skinsdb_unified_inventory_context',"") --reset context
		unified_inventory.set_inventory_formspec(player, "craft")
		return
	end

	if formname ~= "" then
		return
	end

	local context -- read context only if skins related action
	for field, _ in pairs(fields) do
		if field:sub(1,5) == "skins" then
			context = minetest.deserialize(player:get_attribute('skinsdb_unified_inventory_context')) or {}
			break
		end
	end
	if not context then
		return
	end

	local action = skins.on_skin_selection_receive_fields(player, context, fields)
	if action == 'set' then
		player:set_attribute('skinsdb_unified_inventory_context',"") --reset context
		unified_inventory.set_inventory_formspec(player, "skins")
	elseif action == 'page' then
		player:set_attribute('skinsdb_unified_inventory_context', minetest.serialize(context))
		unified_inventory.set_inventory_formspec(player, "skins_page")
	end
end)
