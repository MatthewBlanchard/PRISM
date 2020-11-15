local Component = require "component"

local Move = Component:extend()
Move.name = "Move"

function Move:__new(options)
  self.speed = options.speed
  self.passable = options.passable or false
end

function Move:initialize(actor)
  local moveAction = actions.Move:extend()
  moveAction.time = self.speed or 100

  actor:addAction(moveAction)
  actor.passable = self.passable
end

return Move
