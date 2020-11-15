local Component = require "component"

local Pushable = Component:extend()
Pushable.name = "Pushable"

Pushable.requirements = {
  components.Usable,
}

function Pushable:initialize(actor)
  actor:addUseAction(actions.Push)
end

return Pushable
