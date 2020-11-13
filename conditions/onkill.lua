local Condition = require "condition"

local OnKill = Condition:extend()
OnKill.name = "OnKill"

function OnKill:onKill(level, killer, killed, action)
end

OnKill:afterAction(reactions.Die,
  function(self, level, actor, action)
    local killer = action:getTarget(1)
    self:onKill(level, killer, action.owner, action)
  end
):where(Condition.ownerIsTarget)

return OnKill
