local Actor = require "actor"
local Tiles = require "tiles"

local RobeOfWonders = Actor:extend()
RobeOfWonders.char = Tiles["cloak"]
RobeOfWonders.name = "Robe of Wonders"

RobeOfWonders.components = {
  components.Item(),
  components.Equipment{
    slot = "body",
    effects = {
      conditions.Modifystats{
        MGK = 2,
        MR = 1,
        AC = 1
      },
      conditions.Refundcharge{
        chance = 0.50
      }
    }
  },
  components.Cost{rarity = "rare"}
}

return RobeOfWonders
