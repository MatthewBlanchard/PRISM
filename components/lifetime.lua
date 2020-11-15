local Component = require "component"

local Lifetime = Component:extend()
Lifetime.name = "Lifetime"

function Lifetime:__new(options)
  self.duration = options.duration
end

function Lifetime:initialize(actor)
  local customLifetime = conditions.Lifetime:extend()
  customLifetime:setDuration(self.duration)

  actor:applyCondition(customLifetime)
end

return Lifetime
