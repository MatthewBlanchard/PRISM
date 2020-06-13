local Condition = require "condition"

local Lethargy = Condition()

Lethargy:onAction(actions.Move,
  function(self, level, action)
    action.time = action.time * 2
  end
)

return Lethargy
