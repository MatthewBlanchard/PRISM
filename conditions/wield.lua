local Condition = require "condition"

local WieldCondition = Condition:extend()
WieldCondition.name = "wielded"

WieldCondition:afterAction(actions.Wield,
  function(self, level, action)
    for k, effect in pairs(self.effects) do
      action.owner:applyCondition(effect)
    end
  end
):where(Condition.ownerIsTarget)

WieldCondition:afterAction(actions.Unwield,
  function(self, level, action)
    for k, effect in pairs(self.effects) do
      action.owner:removeCondition(effect)
    end
  end
):where(Condition.ownerIsTarget)

WieldCondition:onAction(actions.Drop,
  function(self, level, action)
    local weapon = action:getTarget(1)

    if not (action.owner.wielded == weapon) then
      return
    end

    local unwield = action.owner:getAction(actions.Unwield)(action.owner, weapon)
    level:performAction(unwield, true)
  end
):where(Condition.ownerIsTarget)

return WieldCondition
