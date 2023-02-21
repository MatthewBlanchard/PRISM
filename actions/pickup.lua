local Action = require "action"

targets.Pickup = targets.Item:extend()
targets.Pickup.name = "pickup"

function targets.Pickup:validate(owner, actor)
  if actor == owner then
    return false -- can't pickup yourself even if you are an item!
  end

  local inventory = owner:getComponent(components.Inventory)
  if inventory and inventory:hasItem(actor) then
    return false -- can't pick up an item if it's in your inventory!
  end

  local equipment = actor:getComponent(components.Equipment)
  local equipper = owner:getComponent(components.Equipper)
  if equipment and equipper and equipper.slots[equipment.slot] == actor then
    return false -- can't pick up an item if it's equipped!
  end

  return targets.Item.validate(self, owner, actor) -- make sure the target is an item
end

local Pickup = Action:extend()
Pickup.name = "pick up"
Pickup.targets = {targets.Pickup}

function Pickup:perform(level)
  local target = self.targetActors[1]
  level:removeActor(target)

  local currency = self.owner:getComponent(components.Currency)
  if currency then 
    self.owner:deposit(getmetatable(target), target.worth)
  else
    local inventory = self.owner:getComponent(components.Inventory)
    inventory:addItem(target)
  end
end

return Pickup
