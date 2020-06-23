local Actor = require "actor"
local Tiles = require "tiles"

local Key = Actor:extend()
Key.name = "Key"
Key.char = Tiles["key"]
Key.color = {0.8, 0.8, 0.1, 1}
Key.description = "A simple key. You wonder what it unlocks."

Key.components = {
	components.Item()
}

return Key