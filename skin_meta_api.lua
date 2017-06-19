skins.meta = {}

local skin_class = {}
skin_class.__index = skin_class
-----------------------
-- Class methods
-----------------------
-- constructor
function skins.new(key, object)
	assert(key, 'Unique skins key required, like "character_1"')
	local self = object or {}
	setmetatable(self, skin_class)
	self.__index = skin_class

	self._key = key
	self._sort_id = 0
	skins.meta[key] = self
	return self
end

-- getter
function skins.get(key)
	return skins.meta[key]
end

-- Skin methods
-- In this implementation it is just access to attrubutes wrapped
-- but this way allow to redefine the functionality for more complex skins provider
function skin_class:get_key()
	return self._key
end

function skin_class:set_meta(key, value)
	self[key] = value
end

function skin_class:get_meta(key)
	return self[key]
end

function skin_class:get_meta_string(key)
	return tostring(self:get_meta(key) or "")
end

function skin_class:set_texture(value)
	self._texture = value
end

function skin_class:get_texture()
	return self._texture
end

function skin_class:set_preview(value)
	self._preview = value
end

function skin_class:get_preview()
	return self._preview or "player.png"
end

function skin_class:set_skin(player)
	player:set_properties({
		visual_size = {
			x = 1,
			y = 1
		}
	})
	player:set_properties({
		textures = {self:get_texture()},
	})
end
