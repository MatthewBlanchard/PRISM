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

function Vector2.__mul(a, b)
  return Vector2(a.x * b, a.y * b)
end

function Vector2:__tostring()
  return "x: " .. self.x .. " y: " .. self.y
end

Vector2.UP = Vector2(0, -1)
Vector2.RIGHT = Vector2(1, 0)
Vector2.DOWN = Vector2(0, 1)
Vector2.LEFT = Vector2(-1, 0)
Vector2.UP_RIGHT = Vector2(1, -1)
Vector2.UP_LEFT = Vector2(-1, -1)
Vector2.DOWN_RIGHT = Vector2(1, 1)
Vector2.DOWN_LEFT = Vector2(-1, 1)


return Vector2
