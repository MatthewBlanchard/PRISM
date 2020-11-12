local Condition = require "condition"

local Regeneration = Condition:extend()
Regeneration.name = "regeneration"

Regeneration:onTick(
  function(self, level, actor)
    local heal = self.owner:getReaction(reactions.Heal)
    level:performAction(heal(actor, {actor}, 1))
  end
)

return Regeneration
