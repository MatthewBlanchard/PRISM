local Condition = require "condition"

local Swiftness = Condition:extend()
Swiftness.name = "Swiftness"
Swiftness.description = "Your actions take 25% less time."

Swiftness:onAction(actions.Move,
  function(self, level, actor, action)
    action.time = action.time * 0.75
  end
)

return Swiftness
