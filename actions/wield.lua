local Action = require "action"

local Wield = Action:extend()
Wield.name = "wield"
Wield.targets = {targets.Weapon}

function Wield:perform(level)
  local weapon = self:getTarget(1)

  self.owner:getComponent(components.Attacker).wielded = weapon
end

return Wield
