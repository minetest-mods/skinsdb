#!/bin/bash
set -e
cd "$(dirname "$0")"
mod_path="$PWD"

workdir="$(mktemp -d /tmp/XXXXXXXX)"
cd "$workdir"
export HOME="$PWD"

mkdir -p .minetest
config="$PWD/.minetest/minetest.conf"
cat << 'EOF' > "$config"
secure.trusted_mods = skinsdb
EOF

world="$PWD/.minetest/worlds/world"
mkdir -p .minetest/worlds/world
cat << 'EOF' > "$world/world.mt"
enable_damage = true
auth_backend = sqlite3
player_backend = sqlite3
backend = sqlite3
creative_mode = false
gameid = minetest
load_mod_skinsdb = true
load_mod_skinsdb_updater_script = true
EOF

mkdir -p .minetest/mods
cp -rv "$mod_path" .minetest/mods/skinsdb

mkdir -p .minetest/mods/skinsdb_updater_script
echo skinsdb > .minetest/mods/skinsdb_updater_script/depends.txt
cat << 'EOF' > .minetest/mods/skinsdb_updater_script/init.lua
minetest.register_on_mods_loaded(function()
  local status, msg = minetest.registered_chatcommands.skinsdb_download_skins.func("", "1 100")
  if status then
    minetest.log("action", msg)
  else
    minetest.log("error", msg)
    minetest.request_shutdown(msg)
  end
end)
EOF

minetestserver --world "$world" --config "$config"

rm -fr "$mod_path/meta" "$mod_path/textures"

mv .minetest/mods/skinsdb/meta .minetest/mods/skinsdb/textures "$mod_path/"

cd "$mod_path"
rm -fr "$workdir"
