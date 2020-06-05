local Action = require "action"

targets.Pickup = targets.Item()
targets.Pickup.name = "pickup"

print(targets.Pickup.requirements[1])
function targets.Pickup:validate(owner, actor)
	if actor == owner then
		return false
	end

	for k, item in pairs(owner.inventory) do
		if item == actor then
			return false
		end
	end

	if owner.slots and owner.slots[actor.slot] == actor then
		return false
	end

	print(targets.Target.validate(self, owner, actor))
	return targets.Target.validate(self, owner, actor)
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
