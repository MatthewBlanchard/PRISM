local Action = require "action"

local Equip = Action:extend()
Equip.name = "equip"
Equip.targets = {targets.Equipment}

function Equip:perform(level)
  local equipper_component = self.owner:getComponent(components.Equipper)
  local equipment_component = self:getTarget(1):getComponent(components.Equipment)

  equipment_component.equipper = self.owner
  equipper_component:setSlot(equipment_component.slot, self:getTarget(1))
  
  for k, effect in pairs(equipment_component.effects) do
    self.owner:applyCondition(effect)
  end
end

return Equip
