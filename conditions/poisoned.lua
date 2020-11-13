local Condition = require "condition"

local Poison = Condition:extend()
Poison.name = "poisoned"
Poison.damage = 1

Poison:setDuration(1000)

Poison:onTick(
  function(self, level, actor)
    local damage = actor:getReaction(reactions.Damage)(actor, {self.owner}, self.damage)
    level:performAction(damage)
    level:addEffect(effects.PoisonEffect(actor, self.damage))
  end
)

return Poison
