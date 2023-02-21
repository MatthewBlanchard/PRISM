local Action = require "action"

local Equip = Action:extend()
Equip.name = "equip"
Equip.targets = {targets.Equipment}

function Equip:perform(level)
  local equipper = self.owner:getComponent(components.Equipper)
  local equipment = self:getTarget(1):getComponent(components.Equipment)

  equipper:setSlot(equipment.slot, self:getTarget(1))
end

return Equip
