# skinsdb

This Minetest mod offers changeable player skins with a graphical interface for multiple inventory mods.

## Features

- Download scripts included for the [Minetest skin database](http://minetest.fensta.bplaced.net)
- Flexible skins API to manage the database
- [character_creator](https://github.com/minetest-mods/character_creator) support for custom skins
- Skin change menu for sfinv (in minetest_game) and [unified_inventory](https://forum.minetest.net/viewtopic.php?t=12767)
- Supported by [smart_inventory](https://forum.minetest.net/viewtopic.php?t=16597) for the skin selection
- Skin previews supported in selection
- Additional information for each skin
- Support for different skins lists: public and a per-player list are currently implemented
- Full [3d_armor](https://forum.minetest.net/viewtopic.php?t=4654) support


## Update tools

In order to download the skins from the skin database,
you may use one of the listed update tools below.
They are located in the `updater/` directory.

- `update_skins_db.sh` bash and jq required
- `update_from_db.py` python3 required
- `MT_skins_updater.*` windows or mono (?) required


## License

If nothing else is specified, it is licensed as GPLv3.

Fritigern:
  - update_skins_db.sh (CC-BY-NC-SA 4.0)

### Credits

- RealBadAngel (unified_inventory)
- Zeg9 (skinsdb)
- cornernote (source code)
- Krock (source code)
- bell07 (source code)