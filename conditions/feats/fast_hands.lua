local Condition = require "condition"

local Finesse = Condition:extend()
Finesse.name = "Fast Hands"
Finesse.description = "Your hands are dangerously fast. The faster your attack the more damage!"

Finesse:onAction(actions.Attack,
  function(self, level, actor, action)
    action.bonusDamage = math.min(5, math.max(0, action.speed/25))
  end
)

return Finesse
