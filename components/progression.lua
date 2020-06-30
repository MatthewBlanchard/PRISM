local Component = require "component"

local Progression = Component:extend()
Progression.requirements = {components.Stats}

function Progression:initialize(actor)
  actor.levels = {STR = 0, DEX = 0, CON = 0, INT = 0, WIS = 0}
  actor.feats = {}
  actor:addAction(actions.LevelUp)
end

return Progression