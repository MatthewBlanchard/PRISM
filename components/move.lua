local Component = require "component"

local Move = Component:extend()

function Move:__new(speed, blocksMovement)
  self.speed = speed
  self.passable = blocksMovement or false
end

function Move:initialize(actor)
  local moveAction = actions.Move:extend()
  moveAction.time = self.speed or 100

  actor:addAction(moveAction)
  actor.passable = self.passable
end

return Move
