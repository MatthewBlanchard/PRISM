local Actor = require "actor"
local Vector2 = require "vector"
local Tiles = require "tiles"

local Gazer = Actor:extend()

Gazer.char = Tiles["gazer"]
Gazer.name = "gazer"
Gazer.color = {0.8, 0.8, 0.8}

Gazer.components = {
  components.Sight{range = 8, fov = true, explored = false},
  components.Move{speed = 115, passable = false},
  components.Stats
  {
    ATK = 0,
    MGK = 3,
    PR = 0,
    MR = 0,
    maxHP = 7,
    AC = 3
  },
  components.Aicontroller(),
  components.Realitydistortion(),
  components.Animated()
}

local actUtil = components.Aicontroller
function Gazer:act(level)
  return actUtil.randomMove(level, self)
end

return Gazer
