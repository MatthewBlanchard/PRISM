local Actor = require "actor"
local Tiles = require "tiles"

local RingOfProtection = Actor:extend()
RingOfProtection.char = "o"
RingOfProtection.name = "Ring of Protection"

RingOfProtection.components = {
  components.Item(),
  components.Equipment{
    slot = "ring",
    effects = {
      conditions.Modifystats{
        AC = 1
      }
    }
  }
}

return RingOfProtection
