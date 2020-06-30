local Condition = require "condition"

local Rapidfire = Condition:extend()
Rapidfire.name = "Rapid Fire"
Rapidfire.description = "Throw things 25% faster."

Rapidfire:onAction(actions.Throw,
  function(self, level, actor, action)
    action.time = action.time * 0.75
  end
)

return Rapidfire