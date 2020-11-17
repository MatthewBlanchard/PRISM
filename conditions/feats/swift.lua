local Condition = require "condition"

local Swift = Condition:extend()
Swift.name = "Elusive Prey"
Swift.description = "When wounded you move 25 faster and can't be slowed down."

Swift:setTime(actions.Move,
  function(self, level, actor, action)
    if actor:getHP() <= actor:getMaxHP()/2 then
      action.time = math.min(action.time, 75)
    end
  end
)

return Swift
