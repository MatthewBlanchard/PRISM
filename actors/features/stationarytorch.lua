local Actor = require "actor"
local Tiles = require "tiles"

local StationaryTorch = Actor:extend()
StationaryTorch.char = Tiles["stationarytorch"]
StationaryTorch.name = "StationaryTorch"
StationaryTorch.color = {0.5, 0.5, 0.8}

StationaryTorch.components = {
  components.Light{
    color = {0.5, 0.5, 0.8},
    intensity = 2
  }
}

return StationaryTorch
