local Actor = require "actor"
local Tiles = require "tiles"

local Glowshroom = Actor:extend()
Glowshroom.char = Tiles["glowshroom"]
Glowshroom.name = "Glowshroom"
Glowshroom.color = { 0.5, 0.9, 0.5, 1}

Glowshroom.components = {
  components.Light{
    color = { 0.4, 0.7, 0.4, 1},
    intensity = 1.4
  }
}

return Glowshroom
