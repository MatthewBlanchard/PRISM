--- Core module
-- @module Core

local Object = require "object"
local Vector2 = require "vector"
local Tiles = require "tiles"
local Component = require "component"
local Action = require "action"
local Reaction = require "reaction"

--- Represents entities in the game, including the player, enemies, and items.
--- Actors are composed of Components that define their state and behavior.
--- For example, an actor may have a Sight component that determines their field of vision, explored tiles, and other related aspects.
--- The Sight System handles the mechanics of an actor's sight.
-- @type Actor
local Actor = Object:extend()

--- A collection of the actor's innate actions. This is used mostly for
--- actions that are 'instrinsic' to the actor, such as a spider casting a web.
--- It might be better to use a component for this, and I may change it in the future.
-- @tfield table actions
Actor.actions = nil

--- A collection of the actor's innate reactions. This is hardly ever used
--- and marked for removal.
-- @tfield table reactions
Actor.reactions = nil

-- An actor's Conditions, event handlers that modify the actor's state and actions.
-- @tfield table conditions
Actor.conditions = nil

--- The position of the actor on the map.
-- @tfield Vector2 position
Actor.position = nil

--- The name of the actor.
-- @tfield string name
Actor.name = "actor"

--- Defines whether the actor can be moved through.
-- @tfield boolean passable
Actor.passable = true

--- Defines whether the actor can be seen.
-- @tfield boolean passable
Actor.visible = true 

--- Defines the actor's base color.
-- @tfield table color
Actor.color = { 1, 1, 1, 1 }

--- Defines whether the actor's color should be used instead of it's lit color.
-- @tfield boolean emissive
Actor.emissive = false

--- Defines the actor's offset in the sprite sheet.
-- @field offset integer
Actor.char = Tiles["player"]

--- Whether to conjugate verbs when referring to the actor.
-- @tfield conjugate boolean
Actor.conjugate = true 

--- The pronoun to use when referring to the actor.
-- @tfield string pronoun
Actor.pronoun = "it" -- the pronoun for the actor

--- The article to use when referring to the actor.
-- @tfield string article
Actor.article = "a" -- the article for the actor


--- Constructor for an actor.
-- Initializes and copies the actor's fields from it's prototype.
-- @function Actor:__new
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
      -- Catch any components that are not of the Component type on initialization to prevent errors later.
      assert(component:is(Component), "Actor " .. self.name .. " has a component that is not of Component type!")

      if not component:checkRequirements(self) then
        error("Not all requirements present for component " .. component.name .. " in actor " .. self.name .. "!")
      end

      -- This is a hack to prevent components from being shared between actors by copying
      -- the prototype's 
      temp[k] = component:new()
    end

    self.components = temp
  else
    self.components = {}
  end

  self:initializeComponents()
end

--- Called after an actor is added to a level and it's components are initialized.
-- @function Actor:initialize
-- @tparam Level level The level the actor is being added to.
function Actor:initialize(level)
  -- you should implement this in your own actor for things like
  -- applying conditions that are innate to the actor.
end


-- 
-- Components 
--


--- Initializes the actor's components.
-- @function Actor:initializeComponents
function Actor:initializeComponents()
  for k, component in ipairs(self.components) do
    component:initialize(self)
  end
end

--- Adds a component to the actor. This function will check if the component's
--- prerequisites are met and will throw an error if they are not.
-- @function Actor:addComponent
-- @tparam Component component The component to add to the actor.
function Actor:addComponent(component)
  assert(component:is(Component), "Expected argument component to be of type Component!")

  if not component:checkRequirements(self) then
    error("Unsupported component added to actor!")
  end

  table.insert(self.components, component)
end

--- Removes a component from the actor. This function will throw an error if the
--- component is not present on the actor.
-- @function Actor:removeComponent
-- @tparam Component component The component to remove from the actor.
function Actor:removeComponent(component)
  assert(component:is(Component), "Expected argument component to be of type Component!")

  for i = 1, #self.components do
    if self.components[i]:is(component) then
      table.remove(self.components, i)
      return
    end
  end
end

--- Returns a bool indicating whether the actor has a component of the given type.
-- @function Actor:hasComponent
-- @tparam Component type The prototype of the component to check for.
function Actor:hasComponent(type)
  assert(type:is(Component), "Expected argument type to be inherited from Component!")

  for k, component in pairs(self.components) do
    if component:is(type) then
      return true
    end
  end

  return false
end

-- Returns the first component of the given type that the actor has.
function Actor:getComponent(type)
  for k, component in pairs(self.components) do
    if component:is(type) then
      return component
    end
  end
end


--
-- Actions
--


-- Get a list of actions from the actor and all of it's components.
function Actor:getActions()
  local total_actions = {}

  for k, action in pairs(self.actions) do
    table.insert(total_actions, action)
  end

  for k, component in pairs(self.components) do
    if component.actions then
      for k, action in pairs(component.actions) do
        table.insert(total_actions, action)
      end
    end
  end

  return total_actions
end

-- Add an action to the actor. This function will throw an error if the action
-- is already present on the actor.
function Actor:addAction(action)
  assert(action:is(Action), "Expected argument action to be of type Action!")

  for k, v in pairs(self.actions) do
    if v:is(action) then
      error("Attempted to add existing action to actor!")
    end
  end
  table.insert(self.actions, action)
end

-- Remove an action from the actor. 
function Actor:removeAction(action)
  for k, v in pairs(self.actions) do
    if v:is(action) then
      table.remove(self.actions, k)
      return
    end
  end
end

-- Get's an action from the actor. This function will check the actor's actions
-- and all of it's components for the action.
function Actor:getAction(prototype)
  assert(prototype:is(Action), "Expected argument prototype to be of type Action!")

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

-- Adds a reaction to the actor.
function Actor:addReaction(reaction)
  assert(reaction:is(Reaction), "Expected argument reaction to be of type Reaction!")

  table.insert(self.reactions, reaction)
end

-- Gets the first reaction of the given type that the actor has.
function Actor:getReaction(reaction)
  for k, v in pairs(self.reactions) do
    if v:is(reaction) then
      return v
    end
  end
end


--
-- Conditions
--


-- Attaches a condition to the actor. If the actor already has a condition of
-- the same type and the condition is not stackable, the old condition will be
-- removed.
function Actor:applyCondition(condition)
  if self:hasCondition(getmetatable(condition)) and condition.stackable == false then
    self:removeCondition(condition)
  end

  table.insert(self.conditions, condition)
  condition.owner = self
end

-- Checks if the actor has a condition of the given type.
function Actor:hasCondition(condition)
  for i = 1, #self.conditions do
    if self.conditions[i]:is(condition) then
      return true
    end
  end

  return false
end

-- Removes a condition from the actor. Returns a bool indicating whether the
-- condition was removed.
function Actor:removeCondition(condition)
  for i = 1, #self.conditions do
    if self.conditions[i]:is(condition) then
      table.remove(self.conditions, i)
      return true
    end
  end

  return false
end

-- Returns a list of all conditions that the actor has.
function Actor:getConditions()
  return self.conditions
end


--
-- Utility
--


function Actor:getRange(type, actor)
  return self:getRangeVec(type, actor.position or actor)
end

function Actor:getRangeVec(type, vector)
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

--- A utility function that returns a bool if the actor is visible.
-- @function Actor:isVisible
-- @treturn boolean
function Actor:isVisible()
  local visible = not self.visible
  for k, cond in pairs(self:getConditions()) do
    if cond.isVisible then
      visible = visible or not cond.isVisible()
    end
  end

  return not visible
end

return Actor
