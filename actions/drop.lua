local Action = require "action"

local Vector2 = require "vector"

local Drop = Action:extend()
Drop.name = "drop"
Drop.targets = {targets.Item}

function Drop:perform(level)
  level:moveActor(self.targetActors[1], self.owner.position)
end

return Drop
