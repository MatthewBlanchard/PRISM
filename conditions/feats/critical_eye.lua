local Condition = require "condition"

local CriticalEye = Condition:extend()
CriticalEye.name = "Critical Eye"
CriticalEye.description = "You see opportunities others do not. You crit 5% more often."

CriticalEye:onAction(actions.Damage,
  function(self, level, actor, action)
    action.criticalOn = action.criticalOn - 1
  end
)

return CriticalEye
