local Object = require "object"

local Scheduler = Object:extend()

function Scheduler:__new()
  self.queue = {}
  self.actCount = 0
end

function Scheduler:add(actor, time, lastAct)
  local schedTable = {}
  schedTable.actor = actor
  schedTable.time = 0 or time
  schedTable.lastAct = 0 or lastAct

  table.insert(self.queue, schedTable)
end

function Scheduler:remove(actor)
  for i, schedTable in ipairs(self.queue) do
    if schedTable.actor == actor then
      table.remove(self.queue, i)
      return
    end
  end
end

function Scheduler:has(actor)
  for i, schedTable in ipairs(self.queue) do
    if schedTable.actor == actor then
      return true
    end
  end
end

function Scheduler:addTime(actor, time)
  for i, schedTable in ipairs(self.queue) do
    if schedTable.actor == actor then
      schedTable.time = schedTable.time + time
      return
    end
  end

  error "Attempted to add time to an actor not in the scheduler!"
end

local function sortFunction(a, b)
  -- handling ties in a consistent way is important to us
  -- if two actors are tied the one who acted most recently goes second
  if a.time == b.time then
    return a.lastAct < b.lastAct
  end

  return a.time < b.time
end

function Scheduler:next()
  -- we sort our queue so that those with the least time left to act
  -- end up on top
  table.sort(self.queue, sortFunction)

  -- next we increment our actCount which is essentially used as a timestamp
  -- to consistently break ties
  self.actCount = self.actCount + 1

  -- update this actor's lastAct so that we know when he last acted for tie breaking
  self.queue[1].lastAct = self.actCount

  -- and finally before we return we make a call to updateTime which will
  -- lower all of the actor's time by the amount of the one who's taking it's turn
  self:updateTime(self.queue[1].time)

  --self:debugPrint()
  return self.queue[1].actor
end

function Scheduler:debugPrint()
  for i, schedTable in ipairs(self.queue) do
  end
end

function Scheduler:updateTime(time)
  for i, schedTable in ipairs(self.queue) do
    schedTable.time = schedTable.time - time
  end
end

return Scheduler
