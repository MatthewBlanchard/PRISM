local inflector = require "en"
local Panel = require "panel"

local Message = Panel:extend()

Message.handlers = {}
Message.inflector = inflector()
Message.initialHeight = 5
Message.toggledHeight = 11

function Message:__new(display, parent)
  Panel.__new(self, display, parent, 1, game.display:getHeight() - Message.initialHeight + 1, game.display:getWidth(), Message.initialHeight)
  self.messages = {}
end

function Message:update(dt)
  local actor = game.curActor

  if actor:hasComponent(components.Message) then
    for i, message in ipairs(actor.messages) do
      if type(message) == "string" then
        table.insert(self.messages, message)
      elseif message.targetActors and not message.silent then
        local s = Message.generateString(message)
        table.insert(self.messages, s)
      end
    end

    actor.messages = {}
  end
end

function Message:draw()
  self:drawBorders()
  for i = 1, self.h - 2 do
    local message = self.messages[#self.messages - (i - 1)]
    if message then
      local msg = message:sub(1, 1):upper()..message:sub(2)
      local fadeAmount = (self.h == 11) and i / 3 or i
      self:write(msg, 2, i + 1, {1 / fadeAmount, 1 / fadeAmount, 1 / fadeAmount, 1})
    end
  end
end

function Message:toggleHeight()
  if self.h == Message.initialHeight then 
    self.h = Message.toggledHeight
    self.y = self.y - (Message.toggledHeight - Message.initialHeight)
  else
    self.h = Message.initialHeight
    self.y = self.y + (Message.toggledHeight - Message.initialHeight)
  end
end

function Message.actorString(actor, action)
  local curActor = game.curActor
  local plural
  local ownerstring
  if actor == curActor then
    ownerstring = "you"
    plural = 1
  else
    ownerstring = string.format("%s %s", actor.uniqueName and "" or "the", actor.name)
    plural = 2
  end

  return ownerstring, plural
end

function Message.generateString(action)
  local actor = game.curActor
  local ownerstring, pluralize = Message.actorString(action.owner, action)
  local targetString = Message.actorString(action.targetActors[1], action)

  local verbstring = Message.inflector(action.name, pluralize)

  return string.format("%s %s %s.", ownerstring, verbstring, targetString)
end

return Message
