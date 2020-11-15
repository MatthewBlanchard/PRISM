local Condition = require "condition"

local Rage = Condition:extend()
Rage.name = "anger"
Rage.count = 0

Rage:setDuration(5000)

Rage:onAction(reactions.Die,
  function(self, level, actor, action)
    self.count = self.count + 1
  end
)

function Rage:getATK()
    return self.count * 2
end

return Rage
