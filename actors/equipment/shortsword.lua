local Actor = require "actor"
local Tiles = require "tiles"

local Shortsword = Actor:extend()
Shortsword.char = Tiles["shortsword"]
Shortsword.name = "shortsword"

Shortsword.components = {
  components.Item(),
  components.Weapon{
    stat = "ATK",
    name = "Shortsword",
    dice = "1d6",
    time = 75
  }
}

return Shortsword
