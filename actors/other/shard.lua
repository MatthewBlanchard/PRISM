local Actor = require "actor"
local Tiles = require "tiles"
local Colors = require "colors"

local Shard = Actor:extend()
Shard.name = "shard"
Shard.char = Tiles["shard"]
Shard.color = Colors.BLUE

Shard.components = {
	components.Item(),
	components.Currency{worth = 1}
}

return Shard
