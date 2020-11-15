local Component = require "component"

local Sight = Component:extend()
Sight.name = "Sight"

function Sight:__new(options)
  self.range = options.range
  self.fov = options.fov
  self.explored = options.explored
end

function Sight:initialize(actor)
  actor.getRevealedActors = self.getRevealedActors
  actor.sight = self.range
  actor.seenActors = {}
  actor.scryActors = {}

  if self.fov then
    actor.fov = {}
    if self.explored then
      actor.explored = {}
    end
  end
end

function Sight:getRevealedActors()
  return self.seenActors
end

return Sight
