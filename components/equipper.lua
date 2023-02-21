local Component = require "component"

local Equipper = Component:extend()
Equipper.name = "Equipper"

Equipper.requirements = {
  components.Stats,
  components.Inventory
}

Equipper.actions = {
  actions.Equip,
  actions.Unequip,
}

function Equipper:__new(options)
  self.slots = options
end

function Equipper:initialize()
  -- We need to clone the slots table from our parent actor
  -- so that we don't modify the original table.
  local tmp = self.slots
  self.slots = {} 
  
  for k, v in pairs(tmp) do
    self.slots[k] = v
  end
end

function Equipper:hasSlot(slot)
  for k, v in pairs(self.slots) do
    if k == slot then return true end
  end
end

function Equipper:getSlot(slot)
  return self.slots[slot]
end

function Equipper:setSlot(slot, actor)
  self.slots[slot] = actor
end

return Equipper
