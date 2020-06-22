local Condition = require "condition"

local Regeneration = Condition:extend()
Regeneration.name = "regeneration"

Regeneration:onTick(
  function(self, level, actor)
    actor:setHP(actor:getHP() + 1)
  end
)

return Regeneration
