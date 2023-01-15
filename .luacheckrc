unused_args = false
allow_defined_top = true
max_line_length = 999

globals = {
    "minetest", "unified_inventory", "core",
    "player_api", "clothing", "armor", "sfinv",
}

read_globals = {
    string = {fields = {"split", "trim"}},
    table = {fields = {"copy", "getn"}},
    "hand_monoid",
}
