local Action = require "action"

local Unequip = Action:extend()
Unequip.name = "unequip"
Unequip.targets = {targets.Unequip}

function Unequip:perform(level)
  local equipment = self:getTarget(1)

  self.owner.slots[equipment.slot] = false
end

return Unequip
