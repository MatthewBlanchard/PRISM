local Condition = require "condition"

local OnHit = Condition:extend()
OnHit.name = "OnHit"

function OnHit:onHit(level, attacker, defender, action)
end

OnHit:afterAction(actions.Attack,
  function(self, level, actor, action)
    local defender = action:getTarget(1)
    if action.hit and defender ~= actor then
      self:onHit(level, actor, defender, action)
    end
  end
)

return OnHit
