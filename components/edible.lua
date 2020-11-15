local Component = require "component"

local Edible = Component:extend()
Edible.name = "edible"

Edible.requirements = {
  components.Item,
  components.Usable,
 }

function Edible:__new(options)
  self.nutrition = options.nutrition
end

function Edible:initialize(actor)
  actor.nutrition = self.nutrition
  actor:addUseAction(actions.Eat)
end

return Edible
