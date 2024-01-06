In this folder the skin files could be placed according the following file naming convention.

skinsdb uses an underscore as default seperator for filename splitting which can cause problems with playernames containing "_",
see https://github.com/minetest-mods/skinsdb/issues/54.
The config setting skinsdb_fsep (texture filename seperator) was added as a workaround which also offers "."(dot) as seperator,
dot is the only character which is allowed in textures but not in playernames.
To keep compatibility with older versions underscore is the default value.

fresh install:
you should change the seperator to "." to avoid that problem.
existing install:
- change the filenames according to the naming convention with dot as seperator instead of underscore
- change the texture filename seperator in settings or add "skinsdb_fsep = ." to your minetest.conf before starting your server

Public skin available for all users:
	character_[number-or-name].png

One or multiple private skins for player "nick":
	player_[nick].png or
	player_[nick]_[number-or-name].png

Preview files for public and private skins.
Optional, overrides the generated preview
	character_*_preview.png or
	player_*_*_preview.png
