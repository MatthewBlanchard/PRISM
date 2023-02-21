local Component = require "component"

local Move = Component:extend()
Move.name = "Move"

Move.actions = {
  -- we leave this empty because we create our move action
  -- in the initialize function
}

function Move:__new(options)
  self.speed = options.speed
  self.passable = options.passable or false
end

function Move:initialize(actor)
  -- we create a new move action for each actor that has this component
  -- this allows us to have different speeds for different actors
  local moveAction = actions.Move:extend()
  moveAction.time = self.speed or 100

  self.actions = { 
    moveAction
  }

  -- TODO: The entire passable system needs to be reworked so that there's
  -- a collider component that signals whether or not an actor is passable
  actor.passable = self.passable
end

return Move
