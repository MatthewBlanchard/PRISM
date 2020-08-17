local Tiles = require "tiles"

local effects = {}

effects.HealEffect = function(actor, heal)
  local t = 0
  local lastflip = 9
  return function(dt, interface)
    t = t + dt

    local color = {.1, 1, .1, 1}
    interface:writeOffset(Tiles["heal"], actor.position.x, actor.position.y, color)
    interface:writeOffset(tostring(heal), actor.position.x + 1, actor.position.y, color)
    if t > .4 then return true end
  end
end

effects.PoisonEffect = function(actor, damage)
  local t = 0
  return function(dt, interface)
    t = t + dt

    local color = {.1, .7, .1, 1}
    interface:writeOffset(Tiles["pointy_poof"], actor.position.x, actor.position.y, color)
    interface:writeOffset(tostring(damage), actor.position.x + 1, actor.position.y, color)
    if t > .2 then return true end
  end
end

local function cmul(c1, s)
  return {c1[1] * s, c1[2] * s, c1[3] * s}
end

effects.OpenEffect = function(actor)
  local t = 0
  local lastflip = 9
  return function(dt, interface)
    t = t + dt

    local color = {1, 1, .1, 1}
    if t < .5 then
      local c = cmul(color, t / 0.5)
      interface:writeOffset(Tiles["pointy_poof"], actor.position.x, actor.position.y, c)
    elseif t < .8 then
      interface:writeOffset(Tiles["chest_open"], actor.position.x, actor.position.y, actor.color)
    else
      return true
    end
  end
end

effects.DamageEffect = function(source, position, dmg, hit)
  local t = 0

  local dirx, diry = position.x - source.x, position.y - source.y

  local char = "/"
  if dirx < 0 then
    char = "\\"
  elseif dirx == 0 then
    char = "|"
  end

  return function(dt, interface)
    local color
    if hit == false then
      color = {.6, .6, .6, 1}
    else
      color = {1, .1, .1, 1}
    end

    local dmgstring = tostring(dmg)
    local dmglen = string.len(dmgstring)

    interface:writeOffset(char, position.x, position.y, color)

    if hit then
      local xoffset = math.min(dirx * dmglen, 1)
      local xoffset = xoffset == 0 and 1 or xoffset
      interface:writeOffset(dmgstring, position.x + xoffset, position.y, color)
    end

    t = t + dt
    if t > .2 then return true end
  end
end

return effects
