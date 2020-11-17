local Condition = require "condition"

local Delver = Condition:extend()
Delver.name = "Know It All"
Delver.description = "You always know the location of the exit. I bet you're fun at parties."

Delver:onScry(
  function(self, level, actor)
    return { level:getActorByType(actors.Stairs) }
  end
)

return Delver
