local Action = require "action"

targets.Pickup = targets.Item:extend()
targets.Pickup.name = "pickup"

function targets.Pickup:validate(owner, actor)
  if actor == owner then
    return false -- can't pickup yourself even if you are an item!
  end

  for k, item in pairs(owner.inventory) do
    if item == actor then
      return false -- can't pick up an item if it's in your inventory!
    end
  end

  if owner.slots and owner.slots[actor.slot] == actor then
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

  if target.worth then 
    self.owner:deposit(getmetatable(target), target.worth)
  else
    table.insert(self.owner.inventory, target)
  end
end

return Pickup
