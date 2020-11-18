local Action = require "action"

local ThrowTarget = targets.Point:extend()
ThrowTarget.name = "throwtarget"
ThrowTarget.range = 6

local Throw = Action()
Throw.name = "throw"
Throw.range = 6
Throw.targets = {targets.Item, ThrowTarget}

function Throw:perform(level)
  local thrown = self.targetActors[1]
  local point = self.targetActors[2]

  level:addEffect(effects.throw(thrown, self.owner, point))
  level:moveActor(thrown, point)
end

return Throw
