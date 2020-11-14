local Actor = require "actor"
local Vector2 = require "vector"
local Tiles = require "tiles"

local Webweaver = Actor:extend()

Webweaver.char = Tiles["spider"]
Webweaver.name = "webweaver"
Webweaver.color = {0.7, 0.7, 0.9}

Webweaver.components = {
  components.Sight{ range = 12, fov = true, explored = false },
  components.Move{ speed = 75, passable = false },
  components.Stats
  {
    DEX = 12,
    maxHP = 18,
    AC = 13
  },

  components.Attacker
  {
    defaultAttack =
    {
      name = "Fangs",
      stat = "DEX",
      dice = "1d2",
    }
  },

  components.Intrinsic{
    action = actions.Web
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
    local targetRange = target:getRange("box", self)
    if targetRange == 1 then
      return self:getAction(actions.Attack)(self, target)
    elseif target:hasCondition(conditions.Slowed) then
      return actUtil.moveToward(self, target)
    elseif targetRange >= 2 and targetRange <= 4 then
      return self:getAction(actions.Web)(self, target)
    elseif target:getRange("box", self) <= 2 then
      return actUtil.moveAway(self, target)
    else
      return actUtil.moveToward(self, target)
    end
  else
    return actUtil.randomMove(level, self)
  end
end

return Webweaver
