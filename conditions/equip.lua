local Condition = require "condition"

EquipCondition = Condition:extend()

EquipCondition:afterAction(actions.Equip,
  function(self, level, action)
    for k, effect in pairs(self.effects) do
      action.owner:applyCondition(effect)
    end
  end
):where(Condition.ownerIsTarget)

EquipCondition:afterAction(actions.Unequip,
  function(self, level, action)
    for k, effect in pairs(self.effects) do
      action.owner:removeCondition(effect)
    end
  end
):where(Condition.ownerIsTarget)

EquipCondition:onAction(actions.Drop,
  function(self, level, action)
    local equipment = action:getTarget(1)
    local unequip = action.owner:getAction(actions.Unequip)(action.owner, equipment)
    level:performAction(unequip)
  end
):where(Condition.ownerIsTarget)

return EquipCondition
