local Actor = require "actor"
local Tiles = require "tiles"

local Longsword = Actor:extend()
Longsword.char = Tiles["shortsword"]
Longsword.name = "longsword"

Longsword.components = {
  components.Item(),
  components.Weapon{
    stat = "STR",
    name = "Longsword",
    dice = "1d8",
    time = 100
  }
}

return Longsword
