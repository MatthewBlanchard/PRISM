local inflector = require "en"
local Panel = require "panel"

local Message = Panel:extend()

Message.handlers = {}
Message.inflector = inflector()
Message.initialHeight = 5
Message.toggledHeight = 11

function Message:__new(display, parent)
  Panel.__new(self, display, parent, 1, game.display:getHeight() - Message.initialHeight + 1, game.display:getWidth(),
    Message.initialHeight)
  self.messages = {}
end

Message.combos = {
  [actions.Attack] = {
    [reactions.Die] = false
  }
}

local function combine(actionStack, curAction, curTable, first)
  first = first or true

  if type(curAction) == "string" then
    return curAction
  end

  for k, v in pairs(curTable) do
    if curAction:is(k) then
      local curString = Message.generateString(curAction)

      if not v then
        return curString
      elseif type(v) == "table" then
        local curAction = table.remove(actionStack, 1)

        if curAction then
          return curString .. " " .. combine(actionStack, curAction, v, false)
        else
          return curString
        end
      end
    end
  end

  if first then
    return Message.generateString(curAction)
  end

  table.insert(actionStack, 1, curAction)
  return ""
end

function Message:update(dt)
  local actor = game.curActor
  local messageStack = {}

  local message_component = actor:getComponent(components.Message)
  if message_component then
    for i, message in ipairs(message_component.messages) do
      if type(message) == "string" then
        table.insert(messageStack, message)
      elseif message.targetActors and not message.silent then
        table.insert(messageStack, message)
      end
    end

    local pop = table.remove(messageStack, 1)
    while pop do
      table.insert(self.messages, combine(messageStack, pop, Message.combos))
      pop = table.remove(messageStack, 1)
    end

    message_component.messages = {}
  end
end

function Message:draw()
  self:clear()
  self:drawBorders()
  for i = 1, self.h - 2 do
    local message = self.messages[#self.messages - (i - 1)]
    if message then
      local msg = message:sub(1, 1):upper() .. message:sub(2)
      local fadeAmount = (self.h == 11) and i / 3 or i
      self:write(msg, 2, i + 1, { 1 / fadeAmount, 1 / fadeAmount, 1 / fadeAmount, 1 })
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

  local verbstring = Message.inflector(action.name, pluralize)

  if action:getTarget(1) and not action.messageIgnoreTarget then
    local targetString = Message.actorString(action.targetActors[1], action)
    local finalString = string.format("%s %s %s.", ownerstring, verbstring, targetString)
    return finalString:sub(1, 1):upper() .. finalString:sub(2)
  else
    local finalString = string.format("%s %s.", ownerstring, verbstring)
    return finalString:sub(1, 1):upper() .. finalString:sub(2)
  end
end

return Message
