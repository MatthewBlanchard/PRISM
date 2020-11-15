local Actor = require "actor"
local Tiles = require "tiles"

local BandOfChanneling = Actor:extend()
BandOfChanneling.char = Tiles["ring"]
BandOfChanneling.name = "Band of Channeling"
BandOfChanneling.description= "When you cast a spell magic courses through this ring. It damages everything around you."
BandOfChanneling.components = {
  components.Item(),
  components.Equipment{
    slot = "ring",
    effects = {
      conditions.Channel()
    }
  },
  components.Cost{rarity = "uncommon"}
}

return BandOfChanneling
