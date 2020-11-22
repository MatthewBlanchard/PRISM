local Actor = require "actor"
local Tiles = require "tiles"

local SlippersOfSwiftness = Actor:extend()
SlippersOfSwiftness.char = Tiles["shoes"]
SlippersOfSwiftness.name = "Slippers of Swiftness"

SlippersOfSwiftness.components = {
  components.Item(),
  components.Equipment{
    slot = "boots",
    effects = {
      conditions.Swiftness
    }
  },
  components.Cost{rarity = "rare"}
}

return SlippersOfSwiftness
