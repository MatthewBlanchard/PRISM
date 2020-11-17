local Component = require "component"

local Progression = Component:extend()
Progression.name = "Progression"
Progression.requirements = {components.Stats}

function Progression:initialize(actor)
  actor.level = 1
  actor.feats = {}
  actor:addAction(actions.LevelUp)
end

return Progression
