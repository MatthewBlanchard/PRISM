local Condition = require "condition"

local Pickup = Condition:extend()
Pickup:afterAction(actions.Move,
  function(self, level, actor, action)
    local sight_component = actor:getComponent(components.Sight)
    if not sight_component then return end

    for _, item in pairs(sight_component.seenActors) do
      if item:is(actors.Shard) and actions.Pickup:validateTarget(1, actor, item) then
        return level:performAction(actor:getAction(actions.Pickup)(actor, {item}), true)
      end
    end
  end
)

return Pickup
