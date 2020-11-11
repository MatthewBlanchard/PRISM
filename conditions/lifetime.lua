local Condition = require "condition"

local Lifetime = Condition:extend()
Lifetime.duration = 100
Lifetime.name = "Lifetime"

function Lifetime:onDurationEnd(level, actor)
  level:destroyActor(actor)
end

return Lifetime
