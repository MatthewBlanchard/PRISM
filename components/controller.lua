local Component = require "component"

local Controller = Component:extend()
Controller.inputControlled = true

function Controller:initialize(actor)
	actor.inputControlled = self.inputControlled
end

return Controller
