local Actor = require "actor"
local Tiles = require "tiles"

local StationaryTorch = Actor:extend()
StationaryTorch.char = Tiles["stationarytorch"]
StationaryTorch.name = "StationaryTorch"
StationaryTorch.color = { 0.8666, 0.4509, 0.0862, 1}

StationaryTorch.components = {
  components.Light{
    color = { 0.8666, 0.4509, 0.0862, 1},
    intensity = 2
  }
}

return StationaryTorch
