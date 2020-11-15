local Object = require "object"

-- This is a private class that is exclusively instantiated by Condition.
-- It's returned by Condition's"onX" function cycle.
local Event = Object:extend()

function Event:__new(action, resolutionFunc)
  self.action = action
  self.resolve = resolutionFunc
  self.conditionals = {}
end

function Event:fire(condition, level, actor, action)
  return self.resolve(condition, level, actor, action)
end

function Event:shouldFire(level, action)
  if not action:is(self.action) then return false end

  if #self.conditionals > 0 then
    for k, conditional in pairs(self.conditionals) do
      if not conditional(self.owner.owner, level, action) then return false end
    end

    return true
  end

  if not (self.owner.owner == action.owner) then
    return false
  end

  return true
end

-- This can be called on the events returned by Condition to add additional and arbitrary
-- requirements. For an example check out wield.lua
function Event:where(condFunc)
  table.insert(self.conditionals, condFunc)
end

local Condition = Object:extend()

Condition.onActions = {}
Condition.afterActions = {}
Condition.onTicks = {}
Condition.setTimes = {}

function Condition:extend()
  local self = Object.extend(self)

  -- Since we're defining these as static elements in a table that shouldn't be changed
  -- on instantiated objects we have to copy these tables or all changes will end up on the base
  -- class.
  local oldOnActions, oldAfterActions, oldSetTime = self.onActions, self.afterActions, self.setTimes
  local oldOnTick = self.onTicks
  self.onActions = {}
  self.afterActions = {}
  self.setTimes = {}
  self.onTicks = {}
  self.onScrys = {}

  for k, v in pairs(oldOnActions) do
    self.onActions[k] = v
  end

  for k, v in pairs(oldAfterActions) do
    self.afterActions[k] = v
  end

  for k, v in pairs(oldSetTime) do
    self.setTimes[k] = v
  end

  for k, v in pairs(oldOnTick) do
    self.onTicks[k] = v
  end

  return self
end

-- a helper function to handle condition durations
function Condition:setDuration(duration)
  self:onTick(
    function(self, level, actor)
      self.time = (self.time or 0) + 100

      if self.time > duration then
        if self.onDurationEnd then self:onDurationEnd(level, actor) end
        actor:removeCondition(self)
      end
    end
  )
end

function Condition:getActionEvents(type, level, action)
  local e = {}
  local shouldret = false

  if not self[type] then return false end

  for k, event in pairs(self[type]) do
    event.owner = self
    if type == "onTicks" or type == "onScrys" or event:shouldFire(level, action) then
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

function Condition:onScry(func)
  local e = Event(nil, func)

  table.insert(self.onScrys, e)
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

function Condition:setTime(action, func)
  local e = Event(action, func)

  table.insert(self.setTimes, e)
  return e
end

function Condition:afterReaction(reaction, func)
  return self:afterAction(reaction, func)
end

function Condition.ownerIsTarget(actor, level, action)
  return action:hasTarget(actor)
end

return Condition
