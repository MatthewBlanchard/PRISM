local Condition = require "condition"

local Shield = Condition:extend()
Shield.name = "shield"

function Shield:__new()
  Condition.__new(self)
  self.hasShield = true
end

Shield:onReaction(reactions.Damage,
  function(self, level, actor, action)
    if self.hasShield then
      action.damage = 0
    end
  end
)

return Shield