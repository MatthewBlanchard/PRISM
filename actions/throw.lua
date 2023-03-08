local Action = require "action"

local ThrowTarget = targets.Point:extend()
ThrowTarget.name = "throwtarget"
ThrowTarget.range = 6

local Throw = Action:extend()
Throw.name = "throw"
Throw.range = 6
Throw.targets = {targets.Item, ThrowTarget}

function Throw:perform(level)
  local thrown = self.targetActors[1]
  local point = self.targetActors[2]

  local effects_system = level:getSystem("Effects")
  effects_system:addEffect(effects.throw(thrown, self.owner, point))
  level:moveActor(thrown, point)
end

return Throw
