local Actor = require "actor"
local Tiles = require "tiles"

local Greatsword = Actor:extend()
Greatsword.char = Tiles["shortsword"]
Greatsword.name = "greatsword"

Greatsword.components = {
  components.Item(),
  components.Weapon{
    stat = "STR",
    name = "Greatsword",
    dice = "2d6",
    time = 150
  }
}

return Greatsword
