local Component = require "component"

local Progression = Component:extend()
Progression.requirements = {components.Stats}

function Progression:initialize(actor)
  actor.levels = {ATK = 0, MGK = 0, MR = 0, PR = 0}
  actor.feats = {}
  actor:addAction(actions.LevelUp)
end

return Progression
