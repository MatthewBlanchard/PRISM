local Component = require "component"

local Lock = Component:extend()
Lock.name = "Lock"

function Lock:setKey(item)
  self.key = item
end

function Lock:hasKey(actor)
  local inventory = actor:getComponent(components.Inventory)
  return self.key and inventory and inventory:hasItem(self.key)
end

return Lock
