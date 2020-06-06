local Object = require "object"

local Event = Object:extend()

function Event:__new(action, resolutionFunc)
  self.action = action
  self.resolve = resolutionFunc
  self.conditionals = {}
end

function Event:fire(level, action)
  self.resolve(self.owner.actor, level, action)
end

function Event:shouldFire(level, action)
  if not action:is(self.action) then return false end

  if self.conditionals then
    for k, conditional in pairs(self.conditionals) do
      if not conditional(self.owner.actor, level, action) then return false end
    end

    return true
  else
    if self.owner.actor == action.owner then
      return true
    end
  end

  return true
end

function Event:where(condFunc)
  table.insert(self.conditionals, condFunc)
end

local Condition = Object:extend()

function Condition:__new(type)
  self.type = self.type or type
  self.onActions = self.onActions or {}
  self.afterActions = self.afterActions or {}
end

function Condition:getActionEvents(type, level, action)
  local e = {}
  local shouldret = false

  for k, event in pairs(self[type]) do
    event.owner = self
    if event:shouldFire(level, action) then
      table.insert(e, event)
      shouldret = true
    end
  end

  return shouldret and e or false
end

function Condition:onAction(action, func)
  local e = Event(action, func)

  table.insert(self.onActions, e)
  return e
end

function Condition:onReaction(reaction, func)
  self:onAction(reaction, func)
end

function Condition:afterAction(action, func)
  local e = Event(action, func)
  table.insert(self.afterActions, e)
  return e
end

function Condition:afterReaction(reaction, func)
  self:afterAction(reaction, func)
end

function Condition.ownerIsTarget(actor, level, action)
  return action:hasTarget(actor)
end

return Condition
