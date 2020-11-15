local Actor = require "actor"
local Tiles = require "tiles"

local RingOfRegeneration = Actor:extend()
RingOfRegeneration.char = Tiles["ring"]
RingOfRegeneration.name = "Ring of Vitality"

RingOfRegeneration.components = {
  components.Item(),
  components.Equipment{
    slot = "ring",
    effects = {
      conditions.Modifystats{
        maxHP = 5
      }
    }
  },
  components.Cost{rarity = "common"}
}

return RingOfRegeneration
