local Condition = require "condition"

local Swiftness = Condition:extend()
Swiftness.name = "swiftness"

Swiftness:onAction(actions.Move,
  function(self, level, actor, action)
    action.time = action.time * 0.75
  end
)

return Swiftness
