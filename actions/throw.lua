local Action = require "action"

local ThrowTarget = targets.Target()
ThrowTarget.name = "throwtarget"
ThrowTarget.requirements = {components.Stats}
ThrowTarget.range = 6

local Throw = Action()
Throw.name = "throw"
Throw.targets = {targets.Item, ThrowTarget}

function Throw:perform(level)
  local thrown = self.targetActors[1]
  local target = self.targetActors[2]

  level:moveActor(thrown, target.position)
end

return Throw
