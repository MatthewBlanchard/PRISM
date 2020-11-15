local Component = require "component"

local Message = Component:extend()
Message.name = "message"

function Message:__new()
  self.messages = {}
end

function Message:initialize(actor)
  actor.messages = self.messages
end

return Message
