local Condition = require "condition"

local FullBellyStats = Condition:extend()
FullBellyStats:setDuration(1000)

function FullBellyStats:getATK()
  return 2
end

local FullBelly = Condition:extend()
FullBelly.name = "Mid-fight Snack"
FullBelly.description = "Take a quick bite to gain +2 ATK for 10 seconds. You eat a little faster."

FullBelly:onAction(actions.Eat,
  function(self, level, actor, action)
    action.time = action.time - 25
    action.owner:applyCondition(FullBellyStats())
  end
)

return FullBelly
