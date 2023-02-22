local Object = require "object"
local Actor = require "actor"
local Scheduler = require "scheduler"
local populateMap = require "populater"
local SparseMap = require "sparsemap"
local Vector2 = require "vector"

local Cell = require "cell"
local Wall = require "cells/wall"

local function value(c)
  return (c[1] + c[2] + c[3]) / 3
end

local Level = Object:extend()

function Level:__new(map)
  self.actors = {}
  self.light = {}
  self.effectlight = {}
  self.temporaryLights = {}
  self.effects = {}

  self.scheduler = Scheduler()

  -- we add a special tick to the scheduler that's used for durations and
  -- damage over time effects
  self.scheduler:add("tick")

  self.sparseMap = SparseMap() -- holds a sparse map of actors in the scene by position

  self.fov = ROT.FOV.Recursive(self:getVisibilityCallback())

  -- let's create our map and fill it with the info from the supplied
  -- rotLove map
  self.map = {}
  self.width = map._width
  self.height = map._height
  map:create(self:getMapCallback())
  populateMap(self, map)

  -- Some initialization on the lighting
  self.lighting = ROT.Lighting(self:getLightReflectivityCallback(), { range = 50, passes = 3 })
  self.lighting:setFOV(self.fov)
  self:updateLighting(false, 0)
end

function Level:update()
  self:updateLighting(false, 0)

  -- no brakes baby
  while true do
    -- check if we should quit before we move onto the next actor
    if self.shouldQuit then return love.event.push('quit') end

    -- ok I lied there are brakes. We return "descend" back to the main thread.
    -- That signals that we're done and that it should scrap this thread and
    -- spin up a new level.
    if self.exit == true then
      return "descend"
    end

    local actor = self.scheduler:next()

    assert(actor == "tick" or actor:is(Actor), "Found a scheduler entry that wasn't an actor or tick.")

    if actor == "tick" then
      -- We found the special actor tick which triggers recurring condition effects
      -- like damage over time. It's also used to track durations.
      self.scheduler:addTime(actor, 100)
      self:triggerActionEvents("onTicks")
    else
      if actor.sight then 
        self:updateFOV(actor)
      end

      local action
      if actor:getComponent(components.Controller) then
        -- if we find a player controlled actor we set self.waitingFor and return it
        -- this hands things off to the interface which generates a command for
        -- the actor
        _, action = coroutine.yield(actor)
      else

        -- if we don't have a player controlled actor we ask the actor for it's
        -- next action through it's controller
        -- TODO: don't provide act with level
        action = actor:act(self)
      end

      assert(not (action == nil))
      self:performAction(action)
    end
  end
end

function Level:isScheduled(actor)
  return self.scheduler:has(actor)
end

function Level:addScheduleTime(actor, time)
  self.scheduler:addTime(actor, time)
end

function Level:updateFOV(actor)
  actor.seenActors = {}

  -- check if actor.fov exists and if so we're gonna trash it and start anew
  -- TODO: find a better way to do this that doesn't trash the garbage collector
  if actor.fov then
    local sightLimit = actor.sight

    if self:getCell(actor.position.x, actor.position.y).sightLimit then
      sightLimit = math.min(sightLimit, self:getCell(actor.position.x, actor.position.y).sightLimit)
    end

    actor.fov = {}
    self.fov:compute(actor.position.x, actor.position.y, sightLimit, self:getFOVCallback(actor))

    for x, _ in pairs(actor.fov) do
      for y, _ in pairs(actor.fov[x]) do
        local lighting = self:getLightingAt(x, y, actor.fov, self.light)
        if lighting then
          local lightval = value(lighting)
          if lightval ~= lightval or lightval < actor.darkvision then
            actor.fov[x][y] = false
          end
        else 
          if actor.darkvision ~= 0 then
            actor.fov[x][y] = false
          end
        end    
      end
    end

    self:updateExplored(actor)

    self:updateSeenActors(actor)
    self:updateScryActors(actor)
  end
end

function Level:updateExplored(actor)
  for x, _ in pairs(actor.fov) do
    for y, _ in pairs(actor.fov[x]) do
      if actor.explored then
        if not actor.explored[x] then actor.explored[x] = {} end
        actor.explored[x][y] = self:getCell(x, y)
      end    
    end
  end
end

local function cmul(col, scalar)
  return { col[1] * scalar, col[2] * scalar, col[3] * scalar }
end

local lightinit = false
function Level:updateLighting(effect, dt)
  local lights = {}
  local function add_light(x, y, light_component)
    assert(light_component.is and light_component:is(components.Light))
    local light
    -- Check if we should be manipulating the light with lightingEffects
    -- like flickering or pulsing.
    if light_component.effect and effect then
      light = cmul(light_component.effect(dt), light_component.intensity)
    else
      light = cmul(light_component.color, light_component.intensity)
    end

    -- We don't want to overwrite an exisitng light so if light exists in that cell
    -- we add the two together instead
    local curLight = self.lighting:getLight(x, y)
    if curLight then
      self.lighting:setLight(x, y, ROT.Color.add(light, curLight))
    else
      self.lighting:setLight(x, y, light)
    end
  end

  for actor in self:eachActor(components.Light) do
    add_light(actor.position.x, actor.position.y, actor:getComponent(components.Light))
  end

  for actor in self:eachActor(components.Equipper) do
    local equipper = actor:getComponent(components.Equipper)
    
    for k, v in pairs(equipper.slots) do
      if v and v:getComponent(components.Light) then
        add_light(actor.position.x, actor.position.y, v:getComponent(components.Light))
      end
    end
  end

  local lightsToClean = {}
  local stopIndex = 1

  if #self.temporaryLights > 0 then
    for i = #self.temporaryLights, 1, -1 do
      local light = self.temporaryLights[i]
      local x, y, color = light(dt)

      if not color then table.remove(self.temporaryLights, i) end

      table.insert(lightsToClean, { x, y })
      local curLight = self.lighting:getLight(x, y)
      if curLight then
        self.lighting:setLight(x, y, ROT.Color.add(color, curLight))
      else
        self.lighting:setLight(x, y, color)
      end
    end
  end

  -- We maintain two seperate light buffers. If effect is truthy we give the lighting engine
  -- a callback that fills the effects buffer which does not get used in gameplay and is for
  -- display purposes.
  local callback = effect and self:getLightingEffectCallback() or self:getLightingCallback()
  self.lighting:compute(callback)

  -- Once we've accumulated our light we clear the buffer of the existing lights.
  for _, actor in pairs(self.actors) do
    self.lighting:setLight(actor.position.x, actor.position.y, nil)
  end

  for _, light in ipairs(lightsToClean) do
    self.lighting:setLight(light[1], light[2], nil)
  end
end

function Level:updateEffectLighting(dt)
  self:updateLighting(true, dt)
end

function Level:suppressEffects()
  self.suppressEffect = true
end

function Level:addEffect(effect)
  -- we push the effect onto the effects stack and then the interface
  -- resolves these
  table.insert(self.effects, effect)

  if self.suppressEffect then return end
  coroutine.yield("effect")
end

function Level:resumeEffects()
  self.suppressEffect = false
  coroutine.yield("effect")
end

function Level:invalidateLighting()
  if not self.lighting or not self.lighting.setFOV then return end -- check if lighting is initialized

  -- This resets out lighting. rotLove doesn't offer a better way to do this.
  self.lighting:setFOV(self.fov)
  self:updateLighting(false)
end

function Level:updateScryActors(actor)
  actor.scryActors = {}

  -- we'll use this temporary table to remove duplicates
  local scryed = {}

  local dummy = {}
  for i, condition in ipairs(actor:getConditions()) do
    local e = condition:getActionEvents("onScrys", self) or dummy
    for i, event in ipairs(e) do
      local scryedActors = event:fire(condition, self, actor)

      for _, scryedActor in ipairs(scryedActors) do
        scryed[scryedActor] = true
      end
    end
  end

  for scryActor, _ in pairs(scryed) do
    table.insert(actor.scryActors, scryActor)
  end
end

function Level:grassCheck(actor, other)
  local otherid = self:getCell(other.position.x, other.position.y).grassID
  local id = self:getCell(actor.position.x, actor.position.y).grassID

  if not id and not otherid then return true end
  if not id and otherid then return false end
  if id and not otherid then return true end
  if id == otherid then return true end
  return false
end

function Level:updateSeenActors(actor)
  actor.seenActors = {}

  for k, other in ipairs(self.actors) do
    if (other:isVisible() or actor == other) and
        actor.fov[other.position.x] and
        actor.fov[other.position.x][other.position.y] and
        self:grassCheck(actor, other)
    then
      table.insert(actor.seenActors, other)
    end
  end
end

function Level:addActor(actor)
  -- some sanity checks
  assert(actor:is(Actor), "Attemped to add a non-actor object to the level with addActor")

  actor:initialize(self)
  table.insert(self.actors, actor)
  self.sparseMap:insert(actor.position.x, actor.position.y, actor)

  if actor:hasComponent(components.Aicontroller) or
      actor:hasComponent(components.Controller)
  then
    self.scheduler:add(actor)
  end

  if actor:hasComponent(components.Sight) then
    self:updateFOV(actor)
  end

  if self:influencesLighting(actor) then
    self:invalidateLighting()
  end

  for seen in self:eachActor(components.Sight) do
    self:updateSeenActors(seen)
  end

  self.map[actor.position.x][actor.position.y]:onEnter(self, actor)
end

function Level:hasActor(actor)
  for i = 1, #self.actors do
    if self.actors[i] == actor then
      return i
    end
  end
end

function Level:getActorByType(type)
  for i = 1, #self.actors do
    if self.actors[i]:is(type) then
      return self.actors[i]
    end
  end
end

function Level:removeActor(actor)
  self.sparseMap:remove(actor.position.x, actor.position.y, actor)

  for k, v in ipairs(self.actors) do
    if v == actor then
      table.remove(self.actors, k)
    end
  end

  self.scheduler:remove(actor)

  -- loop through actors with the sight component and recompute their FOV

  -- TODO: more intelligently recompute FOVs by checking if the actor effects FOV
  -- or is in the sightActor's seenActor list
  for sightActor in self:eachActor(components.Sight) do
    self:updateFOV(sightActor)
  end

  if self:influencesLighting(actor) then
    self:invalidateLighting()
  end

  -- We check to make sure there is a player controlled actor left.
  self:checkLoseCondition()
end

function Level:destroyActor(actor)
  for invActor in self:eachActor() do
    local inventory = invActor:getComponent(components.Inventory)
    if inventory then
      if inventory:hasItem(actor) then
        self:addActor(actor)
        inventory:removeItem(actor)
      end
    end
  end

  self:removeActor(actor)

  if self:influencesLighting(actor) then
    self:invalidateLighting()
  end
end

function Level:influencesLighting(actor)
  local blocksVision = actor.blocksVision
  local light_component = actor:getComponent(components.Light)
  local equipper_component = actor:getComponent(components.Equipper)

  local has_equipped_light = false
  if equipper_component then
    
    for k, v in pairs(equipper_component.slots) do
      if v and v:getComponent(components.Light) then
        has_equipped_light = true
      end
    end
  end

  return blocksVision or light_component or has_equipped_light
end

function Level:getActorsAtPosition(x, y)
  local actorsAtPosition = {}
  for i = 1, #self.actors do
    local actorPosition = self.actors[i].position

    if actorPosition.x == x and actorPosition.y == y then
      table.insert(actorsAtPosition, self.actors[i])
    end
  end

  return actorsAtPosition
end

function Level:checkLoseCondition()
  local foundPlayerActor = false

  for i, v in ipairs(self.actors) do
    foundPlayerActor = foundPlayerActor or v:getComponent(components.Controller) ~= nil
  end

  -- set the shouldQuit flag which will be checked in Level.update
  self.shouldQuit = not foundPlayerActor
end

function Level:moveActor(actor, pos)
  assert(pos.is and pos:is(Vector2), "Expected a Vector2 for pos in Level:moveActor.")

  local oldpos = actor.position
  -- we copy the position here so that the caller doesn't have to worry about
  -- allocating a new table
  actor.position = pos:copy()

  -- if this actor exists in another actor's inventory we first remove the item
  -- from their inventory, and then add it to the level.
  local wasInventory = false
  for invActor in self:eachActor(components.Inventory) do
    local inventory = invActor:getComponent(components.Inventory)
    if inventory:hasItem(actor) then
      self:addActor(actor)
      inventory:removeItem(actor)
      wasInventory = true
    end
  end

  self.sparseMap:remove(oldpos.x, oldpos.y, actor)
  self.sparseMap:insert(pos.x, pos.y, actor)

  if actor:hasComponent(components.Sight) then
    self:updateFOV(actor)
  end

  if actor.blocksVision then
    self.lighting:setFOV(self.fov)
  end

  if self:influencesLighting(actor) then
    self:invalidateLighting()
  end

  for seen in self:eachActor(components.Sight) do
    self:updateSeenActors(seen)
  end

  if not wasInventory then
    self.map[oldpos.x][oldpos.y]:onLeave(self, actor)
  end

  self.map[pos.x][pos.y]:onEnter(self, actor)
end

function Level:addEffectAfterAction(effect)
  self.effectAfterAction = effect
end

function Level:performAction(action, free, animationToPlay)
  -- this happens sometimes if one effect kills an entity and a second effect
  -- tries to damage it for instance.
  if not self:hasActor(action.owner) then return end

  self:triggerActionEvents("onActions", action)

  self:addMessage(action)
  action:perform(self)

  self:triggerActionEvents("afterActions", action)
  self:triggerActionEvents("setTimes", action)


  -- if this isn't a reaction or free action and the level contains the acting actor
  -- we update it's place in the scheduler
  if not action.reaction and not free and self:hasActor(action.owner) then
    self.scheduler:addTime(action.owner, action.time)
  end

  self:addEffect(self.effectAfterAction)
  self.effectAfterAction = nil
end

local dummy = {} -- just to avoid making garbage
function Level:triggerActionEvents(onType, action)
  if onType == "onTicks" then
    for _, actor in ipairs(self.actors) do
      for i, condition in ipairs(actor:getConditions()) do
        local e = condition:getActionEvents(onType, self) or dummy
        for i, event in ipairs(e) do
          event:fire(condition, self, actor)
        end
      end
    end

    return
  end

  if not action then return nil end

  for k, condition in ipairs(action.owner:getConditions()) do
    local e = condition:getActionEvents(onType, self, action)
    if e then
      for k, event in ipairs(e) do
        event:fire(condition, self, action.owner, action)
      end
    end
  end

  if not action:getTargets() then return end

  for k, actor in ipairs(action:getTargets()) do
    if actor.getConditions then
      for k, condition in ipairs(actor:getConditions()) do
        local e = condition:getActionEvents(onType, self, action)
        if e then
          for k, event in ipairs(e) do
            event:fire(condition, self, actor, action)
          end
        end
      end
    end
  end
end

function Level:getAOE(type, position, range)
  assert(position:is(Vector2) )
  local seenActors = {}

  if type == "fov" then
    local fov = {}
    self.fov:compute(position.x, position.y, range, self:getAOEFOVCallback(fov))
    for k, other in ipairs(self.actors) do
      if fov[other.position.x] and
          fov[other.position.x][other.position.y]
      then
        table.insert(seenActors, other)
      end
    end

    return fov, seenActors
  elseif type == "box" then
    for k, other in ipairs(self.actors) do
      if other:getRange("box", position) <= range then
        table.insert(seenActors, other)
      end
    end

    return nil, seenActors
  end
end

function Level:addMessage(message, actor)
  -- if they specified an actor we check if they have a message component and
  -- send them and specifically them that message
  if actor and actor:hasComponent(components.Message) then
    local message_component = actor:getComponent(components.Message)
    message_component:add(message)
    return
  end

  -- if actor wasn't specified we send the message to each actor who can see the
  -- message's owner and has a message component
  for actor in self:eachActor(components.Message) do
    local message_component = actor:getComponent(components.Message)
    if actor:hasComponent(components.Sight) then
      for k, v in ipairs(actor.seenActors) do
        if v == message.owner then
          message_component:add(message)
        end
      end
    else
      message_component:add(message)
    end
  end
end

function Level:eachActor(...)
  local n = 1
  local comp = { ... }
  return function()
    for i = n, #self.actors do
      n = i + 1

      if #comp == 0 then
        return self.actors[i]
      end

      for j = 1, #comp do
        if self.actors[i]:hasComponent(comp[j]) then
          return self.actors[i]
        end
      end
    end

    return nil
  end
end

function Level:setCell(x, y, cell)
  self.map[x][y] = cell
end

function Level:getCell(x, y)
  if self.map[x] then
    return self.map[x][y]
  end

  return nil
end

function Level:getCellPassable(x, y)
  if not self:getCell(x, y).passable then
    return false
  else
    for actor, _ in ipairs(self.sparseMap:get(x, y)) do
      if actor.passable == false then
        return false
      end
    end

    return true
  end
end

function Level:getCellPass(x, y)
  return self:getCell(x, y).passable
end

function Level:getCellVisibility(x, y)
  if self:getCell(x, y).opaque then
    return false
  else
    for actor, _ in ipairs(self.sparseMap:get(x, y)) do
      if actor.blocksVision == true then
        return false
      end
    end

    return true
  end
end

-- Some simple callback generation stuff.

function Level:getMapCallback()
  return function(x, y, val)
    if not self.map[x] then self.map[x] = {} end
    
    if val == 0 then
      self.map[x][y] = Cell()
    else
      self.map[x][y] = Wall()
    end
  end
end

function Level:getLightingCallback()
  self.light = {}

  return function(x, y, color)
    if not self.light[x] then self.light[x] = {} end
    self.light[x][y] = color
  end
end

function Level:getLightingEffectCallback()
  return function(x, y, color)
    if not self.effectlight[x] then self.effectlight[x] = {} end
    self.effectlight[x][y] = color
  end
end

function Level:getLightReflectivityCallback()
  return function(lighting, x, y)
    return 0
  end
end

function Level:getVisibilityCallback()
  return function(fov, x, y)
    return self:getCellVisibility(x, y)
  end
end

function Level:getLightingAt(x, y, fov, light)
  if fov[x] and fov[x][y] and not fov[x][y].opaque then
    if light[x] and light[y] then
      return light[x][y]
    end

    return { 0, 0, 0 }
  end

  local finalCol = { 0, 0, 0 }
  local cols = {}

  for i = -1, 1, 1 do
    for j = -1, 1, 1 do
      if fov[x + i] and fov[x + i][y + j] and fov[x + i][y + j].passable then
        if light[x + i] and light[x + i][y + j] then
          table.insert(cols, light[x + i][y + j])
        end
      end
    end
  end

  local count = #cols
  for i = 1, count do
    for j = 1, 3 do
      finalCol[j] = finalCol[j] + cols[i][j]
    end
  end

  for j = 1, 3 do
    finalCol[j] = finalCol[j] / count
  end

  return finalCol
end

function Level:getFOVCallback(actor)
  return function(x, y, z)
    if not actor.fov[x] then actor.fov[x] = {} end
    actor.fov[x][y] = self:getCell(x, y)
  end
end

function Level:getAOEFOVCallback(aoeFOV)
  return function(x, y, z)
    if not self:getCell(x, y).passable then return end

    if not aoeFOV[x] then aoeFOV[x] = {} end
    aoeFOV[x][y] = self:getCell(x, y)
  end
end

function Level:getRandomWalkableTile()
  while true do
    local x, y = ROT.RNG:random(1, self.width), ROT.RNG:random(1, self.height)
    if self:getCellPassable(x, y) then
      return x, y
    end
  end
end

return Level
