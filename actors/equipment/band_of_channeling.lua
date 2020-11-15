local Actor = require "actor"
local Tiles = require "tiles"

local BandOfChanneling = Actor:extend()
BandOfChanneling.char = Tiles["ring"]
BandOfChanneling.name = "Band of Channeling"
BandOfChanneling.desc = "When you cast a spell magic courses through this ring. It damages everything around you."
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
