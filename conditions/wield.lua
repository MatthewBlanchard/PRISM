local Condition = require "condition"

local WieldCondition = Condition:extend()
WieldCondition.name = "wielded"

WieldCondition:afterAction(actions.Wield,
  function(self, level, actor, action)
    for k, effect in ipairs(actor.effects) do
      action.owner:applyCondition(effect)
    end
  end
):where(Condition.ownerIsTarget)

WieldCondition:afterAction(actions.Unwield,
  function(self, level, actor, action)
    for k, effect in pairs(actor.effects) do
      action.owner:removeCondition(effect)
    end
  end
):where(Condition.ownerIsTarget)

WieldCondition:onAction(actions.Drop,
  function(self, level, actor,  action)
    local weapon = action:getTarget(1)

    if not (action.wielded == weapon) then
      return
    end

    local unwield = action:getAction(actions.Unwield)(action, weapon)
    level:performAction(unwield, true)
  end
):where(Condition.ownerIsTarget)

return WieldCondition
