local Component = require "component"

local Move = Component:extend()

function Move:__new(speed)
  self.speed = speed
end

function Move:initialize(actor)
  local moveAction = actions.Move:extend()
  moveAction.time = self.speed or 100

  actor:addAction(moveAction)
  actor.passable = false
end

return Move
