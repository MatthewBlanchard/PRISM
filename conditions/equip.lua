local Condition = require "condition"

local EquipCondition = Condition:extend()
EquipCondition.name = "equipped"

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

    if not (action.owner.slots[equipment.slot] == equipment) then
      return
    end

    local unequip = action.owner:getAction(actions.Unequip)(action.owner, equipment)
    level:performAction(unequip, true)
  end
):where(Condition.ownerIsTarget)

return EquipCondition
