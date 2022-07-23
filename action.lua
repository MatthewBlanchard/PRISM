local Object = require "object"

local Action = Object:extend()
Action.time = 100

function Action:__new(owner, targets)
  if targets and not targets[1] then
    targets = { targets }
  end

  self.owner = owner
  self.name = self.name or "ERROR"
  self.targets = self.targets or {}
  self.targetActors = targets
end

function Action:getTarget(n)
  if self.targetActors[n] then
    return self.targetActors[n]
  end
end

function Action:getNumTargets()
  if not self.targets then return 0 end
  return #self.targets
end

function Action:getTargets()
  return self.targetActors
end

function Action:getTargetObject(index)
  return self.targets[index]
end

function Action:hasTarget(actor)
  for _, a in pairs(self.targetActors) do
    if a == actor then return true end
  end
end

function Action:validateTarget(n, owner, toValidate)
  return self.targets[n]:validate(owner, toValidate)
end

return Action
