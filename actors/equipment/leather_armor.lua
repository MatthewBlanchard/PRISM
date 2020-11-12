local Actor = require "actor"
local Tiles = require "tiles"

local LeatherArmor = Actor:extend()
LeatherArmor.char = Tiles["armor"]
LeatherArmor.name = "Leather Armor"

LeatherArmor.components = {
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

return LeatherArmor
