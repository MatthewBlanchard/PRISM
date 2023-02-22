local Condition = require "condition"

local EquipCondition = Condition:extend()
EquipCondition.name = "equipped"

EquipCondition:afterAction(actions.Equip,
  function(self, level, actor, action)
    local light = action:getTarget(1):getComponent(components.Light)
    local equipment = actor:getComponent(components.Equipment)

    for k, effect in pairs(equipment.effects) do
      action.owner:applyCondition(effect)
    end

    if light then
      level:invalidateLighting()
    end
  end
):where(Condition.ownerIsTarget)

EquipCondition:afterAction(actions.Unequip,
  function(self, level, actor, action)
    local light = action:getTarget(1):getComponent(components.Light)
    local equipment = actor:getComponent(components.Equipment)

    for k, effect in pairs(equipment.effects) do
      action.owner:removeCondition(effect)
    end
    
    if light then
      level:invalidateLighting()
    end
  end
):where(Condition.ownerIsTarget)

EquipCondition:onAction(actions.Drop,
  function(self, level, actor, action)
    local light = action:getTarget(1):getComponent(components.Light)
    local equipment = action:getTarget(1):getComponent(components.Equipment)
    local equipper = action.owner:getComponent(components.Equipper)

    if not (equipper.slots[equipment.slot] == equipment) then
      return
    end

    local unequip = action.owner:getAction(actions.Unequip)(action.owner, equipment)
    level:performAction(unequip, true)

    if light then
      level:invalidateLighting()
    end
  end
):where(Condition.ownerIsTarget)

EquipCondition:onAction(actions.Throw,
  function(self, level, actor, action)
    local light = action:getTarget(1):getComponent(components.Light)
    local equipment = action:getTarget(1):getComponent(components.Equipment)
    local equipper = action.owner:getComponent(components.Equipper)

    if not (equipper.slots[equipment.slot] == equipment) then
      return
    end

    local unequip = action.owner:getAction(actions.Unequip)(action.owner, equipment)
    level:performAction(unequip, true)
    
    if light then
      level:invalidateLighting()
    end
  end
):where(Condition.ownerIsTarget)

return EquipCondition
