local Condition = require "condition"

local FullBellyStats = Condition:extend()
FullBellyStats:setDuration(500)

function FullBellyStats:getATK()
  return 2
end

local FullBelly = Condition:extend()
FullBelly.name = "Mid-fight Snack"
FullBelly.description = "When eat food gain +2 ATK for 5 turns."

FullBelly:onAction(actions.Eat,
  function(self, level, actor, action)
    action.time = action.time - 25
    action.owner:applyCondition(FullBellyStats())
  end
)

return FullBelly
