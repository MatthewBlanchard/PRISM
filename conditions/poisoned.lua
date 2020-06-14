local Condition = require "condition"

local Poison = Condition()
Poison.name = "poison condition"

function Poison:__new(damage, duration, dealer)
  Condition.__new(self)
  self.damage = damage or self.damage
  self.duration = duration or self.duration
end

Poison:onTick(
  function(self, level, actor, condition)
    condition.time = (condition.time or 0) + 100
    local damage = actor:getReaction(reactions.Damage)(actor, condition, condition.damage)
    level:performAction(damage)
    level:addEffect(effects.PoisonEffect(actor, condition.damage))

    if condition.time > condition.duration then
      actor:removeCondition(condition)
    end
  end
)

return Poison
