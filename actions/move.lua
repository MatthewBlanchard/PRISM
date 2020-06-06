local Action = require "action"

local MoveAction = Action:extend()
MoveAction.name = "move"

function MoveAction:__new(owner, direction)
  Action.__new(self, owner)
  self.direction = direction
end

function MoveAction:perform(level)
  local newPosition = self.owner.position + self.direction
  if level:getCellPassable(newPosition.x, newPosition.y) then
    level:moveActor(self.owner, newPosition)
  end
end

return MoveAction
