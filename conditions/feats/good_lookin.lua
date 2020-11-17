local Condition = require "condition"

local GoodLooking = Condition:extend()
GoodLooking.name = "Good Lookin\'"
GoodLooking.description = "You got such a pretty face your opponents wouldn't want to ruin it. You get +2 AC."

function GoodLooking:getAC()
  return 2
end

return GoodLooking
