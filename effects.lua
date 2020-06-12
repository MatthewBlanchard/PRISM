local Tiles = require "tiles"

local effects = {}

effects.HealEffect = function(actor, heal)
  local t = 0
  local lastflip = 9
  return function(dt, interface)
    t = t + dt

    local color = {.1, 1, .1, 1}
    interface:write(Tiles["heal"], actor.position.x, actor.position.y, color)
    interface:write(tostring(heal), actor.position.x + 1, actor.position.y, color)
    if t > .4 then return true end
  end
end

return effects