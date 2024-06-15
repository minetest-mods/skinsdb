local function get_skin(skin_name)
	local skin = skins.get(skin_name)
		or skins.__fuzzy_match_skin_name("(unittest)", skin_name, true)
	return skin and skin:get_key() or nil
end

local function run_unittest()
	local PATH = ":UNITTEST:"

	-- -----
	-- `.`: Simple register + retrieve operations
	skins.register_skin(PATH, "player.DotSep.png")
	skins.register_skin(PATH, "player._DotSep_666_.1.png")

	assert(get_skin("player.DotSep"))
	assert(get_skin("player._DotSep_666_.1"))
	assert(get_skin("player.DotSep.1") == nil)

	-- -----
	-- Ambiguous skin names (filenames without extension). Register + retrieve
	skins.new("player_AmbSki")
	skins.new("player_AmbSki_1")
	skins.new("player_AmbSki_666_1")

	assert(get_skin("player_AmbSki"))
	assert(get_skin("player_AmbSki_") == nil)
	assert(get_skin("player_AmbSki_1"))
	assert(get_skin("player_AmbSki_666_1"))
	-- There are no `__` patterns as they were silently removed by string.split


	-- -----
	-- Mod Storage backwards compatibility
	-- Match the old `_` notation to `.`-separated skins
	skins.register_skin(PATH, "player.ComPat42.png")
	skins.register_skin(PATH, "player.ComPat42.5.png")
	skins.register_skin(PATH, "player._Com_Pat_42.png")
	skins.register_skin(PATH, "player._Com_Pat_42.1.png")

	assert(get_skin("player_ComPat42") == "player.ComPat42")
	assert(get_skin("player_ComPat42_5") == "player.ComPat42.5")
	assert(get_skin("player_Com_Pat_42") == "player._Com_Pat_42")
	assert(get_skin("player_Com_Pat_42_1") == "player._Com_Pat_42.1")


	error("Unittest passed! Please disable them now.")
end

run_unittest()

