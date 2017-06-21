minetest-skinsdb

An skin extention for the Minetest.

Features:
  - a flexible Skins-API to manage a skins database
  - character_creator supported as "custom skin" possible
  - Inventory tabs in sfinv and unified_inventory to select the skins
  - Smart_inventory uses the skinsdb for skins selection
  - Skin previews supported in selection
  - Skin metadata supported showing the selected skin
  - Support for different skins lists. Currently implemented a public list and per-player lists trough skin filenames
  - Full 3d_armor support
  - Previews are used in 3d_armor selection
  - skins download scripts included for the Minetest skin database. (http://minetest.fensta.bplaced.net)

To download the latest there are 3 tools available in "updater" folder:
 "./update_skins_db.sh"    bash and jq required
 "./update_from_db.py"     python3 required
 "MT_skins_updater.exe"    windows required

Licenses:
--------

cornernote:
  - Lua source code (GPLv3)

Fritigern:
  - update_skins_db.sh (CC-BY-NC-SA 4.0)

Krock:
  - Lua source code (GPLv3)
  - MT_skins_updater.exe (WTFPL)
	
bell07:
  - Lua source code (GPLv3)

Credits:
  - RealyBadAngel unified_inventory
  - Zeg9 skinsdb
