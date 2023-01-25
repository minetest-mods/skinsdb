In this folder the skin files could be placed according the following file naming convention.

Notice:
skinsdb uses an underscore as seperator for filename splitting which can lead to problems with playernames containing "_", see https://github.com/minetest-mods/skinsdb/issues/54.
To keep compatibility with older versions the config setting skinsdb_fsep (texture filename seperator) with the default value "_" was added as a workaround.
fresh install:
you should change the seperator to something not allowed in minetest playernames to avoid that problem.
existing install:
- pick a new seperator and change the filenames according to the naming convention with your seperator instead of the underscore
- change the seperator in settings or add "skinsdb_fsep = YOURSEPERATOR" to your minetest.conf before starting your server

Public skin available for all users:
	character_[number-or-name].png

One or multiple private skins for player "nick":
	player_[nick].png or
	player_[nick]_[number-or-name].png

Preview files for public and private skins.
Optional, overrides the generated preview
	character_*_preview.png or
	player_*_*_preview.png
