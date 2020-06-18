local Condition = require "condition"

local Poison = Condition:extend()
Poison.name = "poisoned"
Poison.damage = 1

Poison:setDuration(1000)

Poison:onTick(
  function(self, level, actor, condition)
    local damage = actor:getReaction(reactions.Damage)(actor, condition, condition.damage)
    level:performAction(damage)
    level:addEffect(effects.PoisonEffect(actor, condition.damage))
  end
)

return Poison
