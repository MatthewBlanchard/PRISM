local Action = require "action"

local targetPushable = targets.Actor:extend()
targetPushable.range = 1
targetPushable.requirements = {components.Pushable}

local Push = Action:extend()
Push.name = "push"
Push.targets = {targetPushable}
Push.silent = true

function Push:perform(level)
  local pushable = self:getTarget(1)
  local movement = pushable.position - self.owner.position
  if movement.y == 0 or movement.x == 0 then
	level:performAction(pushable:getAction(actions.Move)(pushable, movement), true)
	level:performAction(self.owner:getAction(actions.Move)(self.owner, movement))
  end
end

return Push
