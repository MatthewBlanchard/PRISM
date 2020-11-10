local Tiles = require "tiles"
local Color = require "color"

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

effects.OpenEffect = function(actor)
  local t = 0
  local lastflip = 9
  return function(dt, interface)
    t = t + dt

    local color = {1, 1, .1, 1}
    if t < .5 then
      local c = Color.mul(color, t / 0.5)
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

effects.ExplosionEffect = function(fov, origin, range, colors)
    local t = 0
    local duration = .6
    local chars = {}

    -- let's define ourselves a little gradient
    chars[5] = 176
    chars[4] = 176
    chars[3] = 177
    chars[2] = 178
    chars[1] = 179
    chars[0] = 180

    local color = colors or {0.8666, 0.4509, 0.0862}
    return function(dt, interface)
        t = t + dt

        for x, yt in pairs(fov) do
            for y, _ in pairs(yt) do
                local distFactor = math.sqrt(math.pow(origin.x - x, 2) + math.pow(origin.y - y, 2))/(t/(duration/6)*range)
                local fadeFactor = math.min(t/duration, 1)
                local fade = math.max(distFactor, fadeFactor)
                local fade = math.min(fade + love.math.noise(x+t, y+t)/2, 1)
                local char = chars[math.floor(fade * 5)]

                if fade < 0.5 then
                    local yellow = {0.8, 0.8, 0.1}
                    yellow = Color.lerp(yellow, color, fade)
                    interface:writeOffset(char, x, y, yellow)
                elseif fade > .95 then
                elseif fade > .75 then
                    local grey = {0.3, 0.3, 0.3}
                    grey = Color.lerp(color, grey, math.min(fade*3, 1))
                    interface:writeOffset(char, x, y, grey)
                elseif fade < .75 then
                    interface:writeOffset(char, x, y, color)
                end
            end
        end

        if t > duration then return true end
        return false, {x, y, }
    end
end

effects.LightEffect = function(x, y, duration, color, intensity)
  intensity = intensity or 1
  local t = 0
  return function (dt)
      t = t + dt
      if t > duration then return false end
      return x, y, Color.mul(Color.mul(color,intensity), (1 - t/duration)*2)
  end
end

effects.Character = function(x, y, char, color, duration)
  local t = 0
  return function (dt, interface)
    t = t + dt
    if t > duration then print("doot") return true end

    interface:writeOffset(char, x, y, color)
  end
end

effects.CharacterDynamic = function(actor, x, y, char, color, duration)
  local t = 0
  return function (dt, interface)
    t = t + dt
    if t > duration then return true end

    interface:writeOffset(char, actor.position.x + x, actor.position.y + y, color)
  end
end

return effects
