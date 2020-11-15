local Actor = require "actor"
local Tiles = require "tiles"

local Shopkeep = Actor:extend()
Shopkeep.name = "Shopkeep"
Shopkeep.char = Tiles["shop"]
Shopkeep.color = {0.5, 0.5, 0.8}
Shopkeep.passable = false

Shopkeep.components = {
}

return Shopkeep
