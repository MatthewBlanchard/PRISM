local Component = require "component"

local Progression = Component:extend()
Progression.name = "Progression"
Progression.requirements = {components.Stats}

Progression.actions = {actions.Level}

function Progression:initialize(actor)
  actor.level = 1
  actor.feats = {}
end

return Progression
