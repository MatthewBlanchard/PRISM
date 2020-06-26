local Action = require "action"

targets.Pickup = targets.Item:extend()
targets.Pickup.name = "pickup"

function targets.Pickup:validate(owner, actor)
  if actor == owner then
    print("ya")
    return false
  end

  for k, item in pairs(owner.inventory) do
    if item == actor then
      print "Nah"
      return false
    end
  end

  if owner.slots and owner.slots[actor.slot] == actor then
    print "blah"
    return false
  end

  return targets.Item.validate(self, owner, actor)
end

local Pickup = Action:extend()
Pickup.name = "pick up"
Pickup.targets = {targets.Pickup}

function Pickup:perform(level)
  local target = self.targetActors[1]
  level:removeActor(target)
  table.insert(self.owner.inventory, target)
end

return Pickup
