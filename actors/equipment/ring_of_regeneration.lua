local Actor = require "actor"
local Tiles = require "tiles"

local RingOfRegeneration = Actor:extend()
RingOfRegeneration.char = Tiles["ring"]
RingOfRegeneration.name = "Ring of Regeneration"

RingOfRegeneration.components = {
  components.Item(),
  components.Equipment{
    slot = "ring",
    effects = {
      conditions.Regeneration()
    }
  }
}

return RingOfRegeneration
