# Skinsdb Interface

## skins.get_player_skin(player)
Return the skin object assigned to the player. Returns defaout if nothins assigned

## skins.assign_player_skin(player, skin)
Select the skin for the player. The "skin" parameter could be the skin key or the skin object

## skins.update_player_skin(player)
Update selected skin visuals on player

## skins.set_player_skin(player, skin)
```
skins.assign_player_skin(player, skin)
skins.update_player_skin(player)
```

## skins.get_skinlist(assignment, select_unassigned)
Get a list of skin objects matching to the assignment.

Supported assignments:
  - "player:"..playername - Skins directly assigned to a player

select_unassigned - Select all skins without assignment too (usually the "character_*" skins)


## skins.new(key, object)
Create and register a new skin object for given key
  - key: Unique skins key, like "character_1"
  - object: Optional. Could be a prepared object with redefinitions

## skins.get(key)
Get existing skin object

HINT: During build-up phase maybe the next statement is usefull
```
local skin = skins.get(name) or skins.new(name)
```


# Skin object

## skin:get_key()
Get the unique skin key

## skin:set_texture(texture)
Set the skin texture - usually at the init time only

## skin:get_texture()
Get the skin texture for any reason. Note to apply them the skin:set_skin() should be used

Could be redefined for dynamic texture generation

## skin:set_preview(texture)
Set the skin preview - usually at the init time only

## skin:get_preview()
Get the skin preview

Could be redefined for dynamic preview texture generation

## skin:set_skin(player)
Apply the skin to the player. Is called in skins.update_player_skin()

## skin:set_meta(key, value)
Add a meta information to the skin object

Note: the information is not stored, therefore should be filled each time during skins registration

## skin:get_meta(key)
The next metadata keys are usually filled
  - name - A name for the skin
  - author - The skin author
  - license - THe skin texture license
  - assignment  - is "player:playername" in case the skin is assigned to be privat for a player

## skin:get_meta_string(key)
Same as get_meta() but does return "" instead of nil if the meta key does not exists
