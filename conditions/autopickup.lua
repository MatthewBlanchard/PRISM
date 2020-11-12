local Condition = require "condition"

local Pickup = Condition:extend()
Pickup:afterAction(actions.Move,
  function(self, level, actor, action)
    for _,item in pairs(actor.seenActors) do
      if item:is(actors.Shard) and actions.Pickup:validateTarget(1, actor, item) then
        return level:performAction(actor:getAction(actions.Pickup)(actor, item), true)
      end
    end
  end
)

return Pickup
