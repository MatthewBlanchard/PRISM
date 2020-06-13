local Condition = require "condition"

local Swiftness = Condition()

Swiftness:onAction(actions.Move,
  function(self, level, action)
    action.time = action.time * 0.75
  end
)

return Swiftness
