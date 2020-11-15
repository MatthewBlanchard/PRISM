local Component = require "component"
local Action = require "action"

local IntrinsicAction = Component:extend()
IntrinsicAction.name = "IntrinsicAction"

IntrinsicAction.requirements = {
  components.Aicontroller
}

function IntrinsicAction:__new(options)
  assert(options.action:is(Action))
  self.action = options.action
end

function IntrinsicAction:initialize(actor)
  actor:addAction(self.action)
end

return IntrinsicAction
