local Condition = require "condition"

local Lethargy = Condition()

Lethargy:onTick(
  function(self, level, actor, condition)
    condition.time = (condition.time or 0) + 100

    if condition.time > 1000 then
      actor:removeCondition(condition)
    end
  end
)

Lethargy:onAction(actions.Move,
  function(self, level, action)
    action.time = action.time * 4
  end
)

return Lethargy
