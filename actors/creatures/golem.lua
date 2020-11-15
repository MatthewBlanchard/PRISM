local Actor = require "actor"
local Vector2 = require "vector"
local Tiles = require "tiles"

local Golem = Actor:extend()

Golem.char = Tiles["golem"]
Golem.name = "crystal golem"
Golem.color = {0.4, 0.4, 0.8}

Golem.components = {
  components.Sight{range = 5, fov = true, explored = false},
  components.Move{speed = 100, passable = false},
  components.Stats
  {
    ATK = 2,
    MGK = 0,
    PR = 1,
    MR = 2,
    maxHP = 12,
    AC = 5
  },
  components.Aicontroller()
}

Golem.innateConditions = {
  conditions.Shield()
}

local actUtil = components.Aicontroller
function Golem:act(level)
  return actUtil.randomMove(level, self)
end

return Golem
