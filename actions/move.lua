local Action = require "action"

local Move = Action:extend()
Move.name = "move"
Move.silent = true
Move.targets = {targets.Point}

function Move:__new(owner, direction)
  print("DIRECTION", direction.x, direction.y)
  Action.__new(self, owner, { direction })
end

function Move:perform(level)
  local direction = self:getTarget(1)

  local newPosition = self.owner.position + direction
  if level:getCellPassable(newPosition.x, newPosition.y) then
    level:moveActor(self.owner, newPosition)
  end
end

return Move
