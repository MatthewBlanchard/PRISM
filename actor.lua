local Object = require "object"
local Vector2 = require "vector"
local Tiles = require "tiles"

local Actor = Object:extend()
Actor.passable = true
Actor.color = {1, 1, 1, 1}
Actor.emissive = false
Actor.char = Tiles["player"]
Actor.name = "actor"
Actor.conjugate = true
Actor.heshe = "it"
Actor.aan = "a"

function Actor:__new()
  self.position = Vector2(1, 1)
  self.lposition = self.position

  self.actions = self.actions or {}
  self.reactions = self.reactions or {}
  self.innateConditions = self.innateConditions or {}
  self.conditions = {}

  for k, v in pairs(self.innateConditions) do
    self:applyCondition(v())
  end

  if self.components then
    local temp = {}

    for k, component in pairs(self.components) do
      if not component:checkRequirements(self) then
        error("Unsupported component added to actor!")
      end

      table.insert(temp, component)
    end

    self.components = temp
  else
    self.components = {}
  end

  self:initializeComponents()
end

function Actor:draw(display)
  display:write(self.char, self.position.x, self.position.y)
end

function Actor:addComponent(component)
  if not component:checkRequirements(self) then
    error("Unsupported component added to actor!")
  end

  table.insert(comp, component)
end

function Actor:removeComponent(component)
  for i = 1, #self.components do
    if self.components[i]:is(component) then
      table.remove(self.components, i)
      return
    end
  end
end

function Actor:hasComponent(type)
  for k, component in pairs(self.components) do
    if component:is(type) then
      return true
    end
  end

  return false
end

function Actor:initializeComponents()
  for k, component in pairs(self.components) do
    component:initialize(self)
  end
end

function Actor:addAction(action)
  for k, v in pairs(self.actions) do
    if v:is(action) then
      error("Attempted to add existing action to actor!")
    end
  end
  table.insert(self.actions, action)
end

function Actor:getAction(action)
  for k, v in pairs(self.actions) do
    if v:is(action) then
      return v
    end
  end
end


function Actor:addReaction(reaction)
  table.insert(self.reactions, reaction)
end

function Actor:getReaction(reaction)
  for k, v in pairs(self.reactions) do
    if v:is(reaction) then
      return v
    end
  end
end

function Actor:applyCondition(condition)
  table.insert(self.conditions, condition)
  condition.actor = self
end

function Actor:removeCondition(condition)
  for i = 1, #self.conditions do
    if self.conditions[i]:is(condition) then
      table.remove(self.conditions, i)
      return true
    end
  end

  return false
end

function Actor:getConditions()
  return self.conditions
end

-- utility functions
function Actor:getRange(type, actor)
  if type == "box" then
    local range
    local i = 1
    local a1 = self
    local a2 = actor
    while not range do
      if
      a2.position.x >= a1.position.x - i and
      a2.position.x <= a1.position.x + i and
      a2.position.y >= a1.position.y - i and
      a2.position.y <= a1.position.y + i
      then
        range = i
      end

      i = i + 1
    end

    return range
  else
    return math.sqrt(math.pow(self.position.x - actor.position.x, 2) + math.pow(self.position.y - actor.position.y, 2))
  end
end

return Actor
