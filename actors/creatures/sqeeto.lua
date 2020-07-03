local Actor = require "actor"
local Vector2 = require "vector"
local Tiles = require "tiles"

local Sqeeto = Actor:extend()

Sqeeto.char = Tiles["sqeeto"]
Sqeeto.name = "sqeeto"
Sqeeto.color = {0.8, 0.7, 0.09}

Sqeeto.components = {
  components.Sight{ range = 2, fov = true, explored = false },
  components.Move(),
  components.Stats
  {
    STR = 8,
    DEX = 10,
    INT = 4,
    CON = 8,
    maxHP = 3,
    AC = 13
  },

  components.Attacker
  {
    defaultAttack = 
    {
      name = "Probiscus",
      stat = "DEX",
      dice = "1d1"
    }
  },

  components.Aicontroller()
}

local actUtil = components.Aicontroller
function Sqeeto:act(level)
  if not actUtil.canSeeActor(self, self.actTarget) then self.actTarget = nil end

  if self.actTarget then

  end

  for k, v in pairs(self.seenActors) do
    if v:is(actors.Player) and self:getRange("box", v) == 1 then
        return self:getAction(actions.Attack)(self, v)
    elseif v:hasComponent(components.Light) then
      
    end
  end

  return actUtil.moveTowardLight(level, self)
end

return Sqeeto
