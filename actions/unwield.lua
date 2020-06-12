local Action = require "action"

local Unwield = Action:extend()
Unwield.name = "unwield"
Unwield.targets = {targets.Unwield}

function Unwield:perform(level)
  local weapon = self:getTarget(1)

  self.owner.wielded = nil
end

return Unwield
