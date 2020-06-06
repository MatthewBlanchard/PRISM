local Object = require "object"

local Vector2 = Object:extend()

function Vector2:__new(x, y)
  self.x = x or 0
  self.y = y or 0
end

function Vector2:copy()
  return Vector2(self.x, self.y)
end

function Vector2.__add(a, b)
  return Vector2(a.x + b.x, a.y + b.y)
end

function Vector2.__sub(a, b)
  return Vector2(a.x - b.x, a.y - b.y)
end

function Vector2.__eq(a, b)
  return a.x == b.x and a.y == b.y
end

return Vector2
