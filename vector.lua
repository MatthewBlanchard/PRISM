--- A small collection of mathematical functions and classes.
--@module Math
local Object = require "object"

--- A Vector2 represents a 2D vector with x and y components.
--@type Vector2
local Vector2 = Object:extend()

--- The x component of the vector.
--@field x number
Vector2.x = nil

--- The y component of the vector.
--@field y number
Vector2.y = nil

--- Constructor for Vector2 accepts two numbers, x and y.
--@tparam number x The x component of the vector.
--@tparam number y The y component of the vector.
function Vector2:__new(x, y)
  self.x = x or 0
  self.y = y or 0
end

--- Returns a copy of the vector.
--@treturn Vector2 A copy of the vector.
function Vector2:copy()
  return Vector2(self.x, self.y)
end

--- Adds two vectors together.
--@tparam Vector2 a The first vector.
--@tparam Vector2 b The second vector.
--@treturn Vector2 The sum of the two vectors.
function Vector2.__add(a, b)
  return Vector2(a.x + b.x, a.y + b.y)
end

--- Subtracts vector b from vector a.
--@tparam Vector2 a The first vector.
--@tparam Vector2 b The second vector.
--@treturn Vector2 The difference of the two vectors.
function Vector2.__sub(a, b)
  return Vector2(a.x - b.x, a.y - b.y)
end

--- Checks the equality of two vectors.
--@tparam Vector2 a The first vector.
--@tparam Vector2 b The second vector.
--@treturn boolean True if the vectors are equal, false otherwise.
function Vector2.__eq(a, b)
  return a.x == b.x and a.y == b.y
end

--- Multiplies a vector by a scalar.
--@tparam Vector2 a The vector.
--@tparam number b The scalar.
--@treturn Vector2 The product of the vector and the scalar.
function Vector2.__mul(a, b)
  return Vector2(a.x * b, a.y * b)
end

--- Creates a string representation of the vector.
--@treturn string The string representation of the vector.
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
