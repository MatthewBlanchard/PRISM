local Component = require "component"

local Move = Component:extend()
Move.name = "Move"

Move.actions = {
  -- we leave this empty because we create our move action
  -- in the initialize function
}

function Move:__new(options)
  self.speed = options.speed
end

function Move:initialize(actor)
  -- we create a new move action for each actor that has this component
  -- this allows us to have different speeds for different actors
  local moveAction = actions.Move:extend()
  moveAction.time = self.speed or 100

  self.actions = { 
    moveAction
  }
end

return Move
