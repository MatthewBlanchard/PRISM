local Component = require "component"

local Lock = Component:extend()

function Lock:initialize(actor)
  actor.setKey = self.setKey 
  actor.hasKey = self.hasKey
end

function Lock:setKey(owner, item)
  owner.key = item
end

function Lock:hasKey(actor)
  return self.key and actor.inventory and actor.hasItem(actor, self.key)
end

return Lock