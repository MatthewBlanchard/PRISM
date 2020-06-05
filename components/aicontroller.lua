local Controller = require "components.controller"

local AIController = Controller:extend()
AIController.inputControlled = false

function AIController:__new(options)
	self.act = options and options.act or self.act
end

function AIController:initialize(actor)
	actor.act = self.act
end

return AIController
