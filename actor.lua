local Object = require "object"
local Vector2 = require "vector"
local Tiles = require "tiles"
local Condition = require "condition"

local Actor = Object:extend()
Actor.passable = true
Actor.visible = true
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

    for k, component in ipairs(self.components) do
      if not component:checkRequirements(self) then
        error("Unsupported component added to actor!" .. self.name)
      end

      table.insert(temp, component)
    end

    self.components = temp
  else
    self.components = {}
  end

  self:initializeComponents()
end

function Actor:isVisible()
  local visible = not self.visible
  for k, cond in pairs(self:getConditions()) do
    if cond.isVisible then
      visible = visible or not cond.isVisible()
    end
  end

  return not visible
end

function Actor:addComponent(component)
  if not component:checkRequirements(self) then
    error("Unsupported component added to actor!")
  end

  table.insert(self.components, component)
end

function Actor:removeComponent(component)
  for i = 1, #self.components do
    if self.components[i]:is(component) then
      table.remove(self.components, i)
      return
    end
  end
end

function Actor:hasComponent(type, source)
  for k, component in pairs(self.components) do
    if component:is(type) then
      return true
    end
  end

  return false
end

function Actor:getComponent(type, source)
  for k, component in pairs(self.components) do
    if component:is(type) then
      return component
    end
  end
end

function Actor:initializeComponents()
  for k, component in ipairs(self.components) do
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

function Actor:removeAction(action)
  for k, v in pairs(self.actions) do
    if v:is(action) then
      table.remove(self.actions, k)
      return
    end
  end
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
  if self:hasCondition(getmetatable(condition)) and condition.stackable == false then
    self:removeCondition(condition)
  end

  table.insert(self.conditions, condition)
  condition.owner = self
end

function Actor:hasCondition(condition)
  for i = 1, #self.conditions do
    if self.conditions[i]:is(condition) then
      return true
    end
  end

  return false
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
  return self:getRangeVec(type, actor.position or actor)
end

function Actor:getRangeVec(type, vector)
  local pos = self.position
  if type == "box" then
    local xDist = math.abs(vector.x - pos.x)
    local yDist = math.abs(vector.y - pos.y)
    return math.max(xDist, yDist)
  else
    return math.sqrt(math.pow(pos.x - vector.x, 2) + math.pow(pos.y - vector.y, 2))
  end
end

return Actor
