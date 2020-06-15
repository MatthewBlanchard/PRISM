local Condition = require "condition"

local Invisible = Condition:extend()
Invisible.name = "invisible"

function Invisible:__new()
  Condition.__new(self)
end

function Invisible:isVisible()
  return false
end

return Invisible
