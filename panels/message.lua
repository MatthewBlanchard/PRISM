local inflector = require "en"
local Panel = require "panel"

local Message = Panel:extend()

Message.handlers = {}
Message.inflector = inflector()

function Message:__new(display, parent)
  Panel.__new(self, display, parent, 18, 46, 45, 5)
  self.messages = {}
end

function Message:update(dt)
  local actor = game.curActor

  if actor:hasComponent(components.Message) then
    for i = 1, #actor.messages do
      if actor.messages[i].targetActors and not actor.messages[i].silent then
        local s = Message.generateString(actor.messages[i])
        table.insert(self.messages, s)
      end
    end

    actor.messages = {}
  end
end

function Message:draw()
  self:drawBorders()
  for i = 1, 3 do
    local message = self.messages[#self.messages - (i - 1)]
    if self.messages[#self.messages - (i - 1)] then
      local msg = message:sub(1, 1):upper()..message:sub(2)
      self:write(msg, 2, i + 1, {1 / i, 1 / i, 1 / i, 1})
    end
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
