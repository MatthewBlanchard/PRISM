local Actor = require "actor"
local Tiles = require "tiles"

local Shortsword = Actor:extend()
Shortsword.char = Tiles["armor"]
Shortsword.name = "armor"

Shortsword.components = {
  components.Item(),
  components.Weapon{
    stat = "STR",
    name = "Shortsword",
    dice = "1d6"
  }
}

return Shortsword
