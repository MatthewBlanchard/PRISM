local Actor = require "actor"
local Tiles = require "tiles"

local SlippersOfSwiftness = Actor:extend()
SlippersOfSwiftness.char = Tiles["cloak"]
SlippersOfSwiftness.name = "Slippers of Swiftness"

SlippersOfSwiftness.components = {
  components.Item(),
  components.Equipment{
    slot = "boots",
    effects = {
      conditions.Swiftness
    }
  }
}

return SlippersOfSwiftness
