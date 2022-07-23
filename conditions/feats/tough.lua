local Condition = require "condition"

local Tough = Condition:extend()
Tough.name = "Big Boned"
Tough.description = "You gain 2 additional max HP when you gaze upon a prism. You move a little slower."

function Tough:getMaxHP()
  return self.owner.level * 2
end

Tough:setTime(actions.Move,
  function(self, level, actor, action)
    action.time = action.time + 5
  end
)

return Tough
