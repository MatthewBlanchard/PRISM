local Action = require "action"

local Unwield = Action:extend()
Unwield.name = "unwield"
Unwield.targets = {targets.Unwield}

function Unwield:perform(level)
  local weapon = self:getTarget(1)

  local attacker = self.owner:getComponent(components.Attacker)
  attacker.wielded = attacker.defaultAttack
end

return Unwield
