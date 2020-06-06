local Reaction = require "reaction"

local Die = Reaction:extend()
Die.name = "die"

function Die:perform(level)
  level:destroyActor(self.owner)
end

return Die
