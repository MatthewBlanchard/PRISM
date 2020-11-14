local Actor = require "actor"
local Tiles = require "tiles"

local RingOfBling = Actor:extend()
RingOfBling.char = Tiles["ring"]
RingOfBling.name = "Ring of Bling"

RingOfBling.components = {
  components.Item(),
  components.Equipment{
    slot = "ring",
    effects = {
      conditions.Additionalshards{
        chance = 0.25
      }
    }
  }
}

return RingOfBling
