local Actor = require "actor"
local Tiles = require "tiles"

local Armor = Actor:extend()
Armor.char = Tiles["armor"]
Armor.name = "armor"

Armor.components = {
  components.Item(),
  components.Equipment{
    slot = "armor",
    effects = {
      conditions.Modifystats{
        AC = 4
      }
    }
  }
}

return Armor
