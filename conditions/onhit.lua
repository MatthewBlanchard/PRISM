local Condition = require "condition"

local OnHit = Condition:extend()
OnHit.name = "OnHit"

function OnHit:__new(toApply, chance)
  Condition.__new(self)
  self.toApply = self.toApply or toApply
  self.chance = self.chance or chance or 1
end

OnHit:afterAction(actions.Attack,
  function(self, level, actor, action)
    local defender = action:getTarget(1)
    if action.hit and defender ~= actor then
      if math.random() <= self.chance then
        defender:applyCondition(self.toApply())
      end
    end
  end
)

return OnHit
