local Component = require "component"

local Equipper = Component:extend()
Equipper.name = "Equipper"

Equipper.requirements = {components.Stats, components.Inventory}

function Equipper:__new(options)
  self.slots = options
end

function Equipper:initialize(actor)
  actor.hasSlot = self.hasSlot

  actor.slots = {}
  for k, v in pairs(self.slots) do
    actor.slots[v] = false
  end

  actor:addAction(actions.Equip)
  actor:addAction(actions.Unequip)
end

function Equipper:hasSlot(slot)
  for k, v in pairs(self.slots) do
    if k == slot then return true end
  end
end

return Equipper
