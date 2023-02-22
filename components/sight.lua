local Component = require "component"

local Sight = Component:extend()
Sight.name = "Sight"

function Sight:__new(options)
  self.range = options.range
  self.fov = options.fov
  self.explored = options.explored
  self.darkvision = options.darkvision or 0.25
end

function Sight:initialize(actor)
  actor.getRevealedActors = self.getRevealedActors
  actor.sight = self.range
  actor.seenActors = {}
  actor.scryActors = {}
  actor.darkvision = self.darkvision

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
