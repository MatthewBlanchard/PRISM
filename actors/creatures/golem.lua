local Actor = require "actor"
local Vector2 = require "vector"
local Tiles = require "tiles"

local Golem = Actor:extend()

Golem.char = Tiles["golem"]
Golem.name = "crystal golem"
Golem.color = {0.4, 0.4, 0.8}

Golem.components = {
  components.Sight{range = 5, fov = true, explored = false},
  components.Move(),
  components.Stats
  {
    STR = 13,
    DEX = 10,
    INT = 4,
    CON = 8,
    maxHP = 6,
    AC = 13
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
