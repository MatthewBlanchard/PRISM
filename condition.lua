local Object = require "object"

local Event = Object:extend()

function Event:__new(action, resolutionFunc)
  self.action = action
  self.resolve = resolutionFunc
  self.conditionals = {}
end

function Event:fire(condition, level, actor, action)
  self.resolve(condition, level, actor, action)
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

Condition.onActions = {}
Condition.afterActions = {}
Condition.onTicks = {}

function Condition:extend()
  local self = Object.extend(self)
  local oldOnActions, oldAfterActions = self.onActions, self.afterActions
  local oldOnTick = self.onTicks
  self.onActions = {}
  self.afterActions = {}
  self.onTicks = {}

  for k, v in pairs(oldOnActions) do
    self.onActions[k] = v
  end

  for k, v in pairs(oldAfterActions) do
    self.afterActions[k] = v
  end

  for k, v in pairs(oldOnTick) do
    self.onTicks[k] = v
  end 

  return self
end

function Condition:setDuration(duration)
  self:onTick(
    function(self, level, actor)
      self.time = (self.time or 0) + 100

      if self.time > duration then
        actor:removeCondition(self)
      end
    end
  )
end

function Condition:getActionEvents(type, level, action)
  local e = {}
  local shouldret = false

  for k, event in pairs(self[type]) do
    event.owner = self
    if type == "onTicks" or event:shouldFire(level, action) then
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

function Condition:onTick(func)
  local e = Event(nil, func)

  table.insert(self.onTicks, e)
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
