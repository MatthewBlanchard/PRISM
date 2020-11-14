local Actor = require "actor"
local Tiles = require "tiles"

local BandOfChanneling = Actor:extend()
BandOfChanneling.char = Tiles["ring"]
BandOfChanneling.name = "Band of Channeling"

BandOfChanneling.components = {
  components.Item(),
  components.Equipment{
    slot = "ring",
    effects = {
      conditions.Channel()
    }
  }
}

return BandOfChanneling
