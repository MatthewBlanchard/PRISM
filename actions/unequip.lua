local Action = require "action"

local Unequip = Action:extend()
Unequip.name = "unequip"
Unequip.targets = {targets.Unequip}

function Unequip:perform(level)
  local equipment = self:getTarget(1):getComponent(components.Equipment)
  local equipper = self.owner:getComponent(components.Equipper)

  equipment.equipper = nil
  equipper.slots[equipment.slot] = false

  for k, effect in pairs(equipment.effects) do
    self.owner:removeCondition(effect)
  end
end

return Unequip
