local Component = require "component"

local Progression = Component:extend()
Progression.requirements = {components.Stats}

function Progression:initialize(actor)
  actor.level = 0
  actor.skills = {}
  actor:addAction(actions.LevelUp)
end

return Progression