local Actor = require "actor"
local Tiles = require "tiles"

local RingOfBling = Actor:extend()
RingOfBling.char = Tiles["ring"]
RingOfBling.name = "Ring of Bling"
RingOfBling.description = "Wandering monster stop and stare at this extravagant ring! When you pick up shards sometimes you'll find an extra!"

RingOfBling.components = {
  components.Item(),
  components.Equipment{
    slot = "ring",
    effects = {
      conditions.Additionalshards{
        chance = 0.25
      }
    }
  },
  components.Cost{rarity = "rare"}
}

return RingOfBling
