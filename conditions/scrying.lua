local Condition = require "condition"

local Scrying = Condition:extend()
Scrying.name = "Scrying"
Scrying.damage = 1

Scrying:onScry(
  function(self, level, actor)
    return level:getActorByType(actors.Prism)
  end
)


return Scrying
