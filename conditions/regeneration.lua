local Condition = require "condition"

local Regeneration = Condition:extend()
Regeneration.name = "regeneration"

Regeneration:onTick(
  function(self, level, actor, condition)
    actor:setHP(actor:getHP() + 1)
  end
)

return Regeneration
