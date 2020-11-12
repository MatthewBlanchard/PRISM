local Component = require "component"

local Pushable = Component:extend()

Pushable.requirements = {
  components.Usable,
}

function Pushable:initialize(actor)
  actor:addUseAction(actions.Push)
end

return Pushable
