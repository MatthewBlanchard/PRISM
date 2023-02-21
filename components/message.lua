local Component = require "component"

local Message = Component:extend()
Message.name = "message"

function Message:initialize(actor)
  self.messages = {}
end

function Message:add(message)
  table.insert(self.messages, message)
end

return Message
