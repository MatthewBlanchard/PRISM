local Actor = require "actor"
local Vector2 = require "vector"
local Tiles = require "tiles"

local Webweaver = Actor:extend()

Webweaver.char = Tiles["sqeeto"]
Webweaver.name = "sqeeter"
Webweaver.color = {0.7, 0.7, 0.9}

Webweaver.components = {
  components.Sight{ range = 12, fov = true, explored = false },
  components.Move{ speed = 75, passable = false},
  components.Stats
  {
    STR = 8,
    DEX = 14,
    INT = 4,
    CON = 8,
    maxHP = 20,
    AC = 13
  },

  components.Attacker
  {
    defaultAttack =
    {
      name = "Fangs",
      stat = "DEX",
      dice = "1d6"
    }
  },

  components.Aicontroller()
}

local actUtil = components.Aicontroller
function Webweaver:act(level)
  local target
  local sqeeter = actUtil.closestSeenActorByType(self, actors.Sqeeto)
  local player = actUtil.closestSeenActorByType(self, actors.Player)

  if sqeeter then
    target = sqeeter
  elseif player then
    target = player
  end

  if target then
  else
  end
end

return Webweaver
