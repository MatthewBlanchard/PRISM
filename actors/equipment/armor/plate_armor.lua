local Actor = require "actor"
local Tiles = require "tiles"

local PlateArmor = Actor:extend()
PlateArmor.char = Tiles["armor"]
PlateArmor.name = "Plate Armor"

PlateArmor.components = {
  components.Item(),
  components.Equipment{
    slot = "body",
    effects = {
      conditions.Modifystats{
        AC = 4
      }
    }
  }
}

return PlateArmor
