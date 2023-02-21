local Object = require "object"
local Vector2 = require "vector"
local Tiles = require "tiles"
local Component = require "component"
local Action = require "action"
local Reaction = require "reaction"

local Actor = Object:extend()
Actor.passable = true
Actor.visible = true
Actor.color = { 1, 1, 1, 1 }
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
  self.conditions = {}

  for k,v in pairs(self.actions) do
    self.actions[k] = v:extend()
  end

  if self.components then
    local temp = {}

    for k, component in ipairs(self.components) do
      assert(component:is(Component), "Actor " .. self.name .. " has a component that is not of Component type!")

      if not component:checkRequirements(self) then
        error("Not all requirements present for component " .. component.name .. " in actor " .. self.name .. "!")
      end

      -- BEWARE HACKS AHEAD
      temp[k] = component
    end

    self.components = temp
  else
    self.components = {}
  end

  self:initializeComponents()
end

-- This is called when an actor is added to a level.
function Actor:initialize(level)
  -- you should implement this in your own actor for things like
  -- applying conditions that are innate to the actor.
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
  assert(component:is(Component), "Expected argument component to be of type Component!")

  if not component:checkRequirements(self) then
    error("Unsupported component added to actor!")
  end

  table.insert(self.components, component)
end

function Actor:removeComponent(component)
  assert(component:is(Component), "Expected argument component to be of type Component!")

  for i = 1, #self.components do
    if self.components[i]:is(component) then
      table.remove(self.components, i)
      return
    end
  end
end

function Actor:hasComponent(type)
  assert(type:is(Component), "Expected argument type to be inherited from Component!")

  for k, component in pairs(self.components) do
    if component:is(type) then
      return true
    end
  end

  return false
end

function Actor:getComponent(type)
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
  assert(action:is(Action), "Expected argument action to be of type Action!")

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

function Actor:getAction(prototype)
  assert(prototype:is(Action), "Expected argument prototype to be extended from Action!")

  for _, action in pairs(self.actions) do
    if action:is(prototype) then
      return action
    end
  end

  for _, component in pairs(self.components) do
    if component.actions then 
      for _, action in pairs(component.actions) do
        if action:is(prototype) then
          return action
        end
      end
    end
  end
end

function Actor:addReaction(reaction)
  assert(reaction:is(Reaction), "Expected argument reaction to be of type Reaction!")

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
  print(vector.x, vector.y)
  assert(vector.is and vector:is(Vector2), "Expected argument vector to be of type Vector2!")

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
