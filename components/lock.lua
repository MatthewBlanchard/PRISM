local Component = require "component"

local Lock = Component:extend()
Lock.name = "Lock"

function Lock:initialize(actor)
  actor.setKey = self.setKey
  actor.hasKey = self.hasKey
end

function Lock:setKey(item)
  self.key = item
end

function Lock:hasKey(actor)
  return self.key and actor.inventory and actor.hasItem(actor, self.key)
end

return Lock
