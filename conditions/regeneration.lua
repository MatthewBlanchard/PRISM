local Condition = require "condition"

local Regeneration = Condition()

Regeneration:onTick(
  function(self, level, actor, condition)
    actor:setHP(actor:getHP() + 1)
  end
)

return Regeneration
