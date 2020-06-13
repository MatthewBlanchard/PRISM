local Condition = require "condition"

local Swiftness = Condition()

Swiftness:onAction(actions.Move,
  function(self, level, action)
    action.time = 25
  end
)

return Swiftness
