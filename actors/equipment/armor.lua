local Actor = require "actor"
local Tiles = require "tiles"

local Armor = Actor:extend()
Armor.char = Tiles["armor"]
Armor.name = "Armor"

Armor.components = {
  components.Item(),
  components.Equipment{
    slot = "body",
    effects = {
      conditions.Modifystats{
        AC = 2
      }
    }
  }
}

return Armor
