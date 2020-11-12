local Actor = require "actor"
local Tiles = require "tiles"

local ClothArmor = Actor:extend()
ClothArmor.char = Tiles["armor"]
ClothArmor.name = "Cloth Armor"

ClothArmor.components = {
  components.Item(),
  components.Equipment{
    slot = "body",
    effects = {
      conditions.Modifystats{
        AC = 1
      }
    }
  }
}

return ClothArmor
