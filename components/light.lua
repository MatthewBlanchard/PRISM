local Component = require "component"

local function randBiDirectional()
  return (math.random() - .5) * 2
end

local function flicker(baseColor, period, intensity)
  local t = 0
  local color = {baseColor[1], baseColor[2], baseColor[3], baseColor[4]}
  return function(dt)
    t = t + dt

    if t > period then
      t = 0
      local r = randBiDirectional() * intensity
      color[1] = baseColor[1] - baseColor[1] * r
      color[2] = baseColor[2] - baseColor[1] * r
      color[3] = baseColor[3] - baseColor[1] * r
    end

    return color
  end
end

local function pulse(baseColor, period, intensity)
  local t = 0
  local color = {baseColor[1], baseColor[2], baseColor[3], baseColor[4]}
  return function(dt)
    t = t + dt

    local r = math.sin(t / period) * intensity
    color[1] = baseColor[1] + baseColor[1] * r
    color[2] = baseColor[2] + baseColor[2] * r
    color[3] = baseColor[3] + baseColor[3] * r

    return color
  end
end

local Light = Component:extend()
Light.name = "Light"

Light.effects = {
  flicker = flicker,
  pulse = pulse
}

function Light:__new(options)
  self.color = options.color
  self.intensity = options.intensity
  self.effect = options.effect
end

function Light:initialize(actor)
  actor.light = self.color
  actor.lightIntensity = self.intensity
  actor.lightEffect = self.effect
end

return Light
