local Object = require "object"
local Scheduler = require "scheduler"
local populateMap = require "populater"

local Level = Object:extend()

function Level:__new(map)
  self.map = {}
  self.width = map._width
  self.height = map._height

  self.temporaryLights = {}
  self.light = {}
  self.actors = {}
  self.effects = {}

  self.scheduler = Scheduler()

  self.fov = ROT.FOV.Recursive(self:getVisibilityCallback())

  self.lighting = ROT.Lighting(self:getLightReflectivityCallback(), {range = 50, passes = 3})
  self.lighting:setFOV(self.fov)

  map:create(self:getMapCallback())

  -- temporary code before we get more complicated level gen in
  -- just pop a few doors where rotLove's level gen indicates
  populateMap(self, map)
end

local initialized
local waitingFor
function Level:update(dt, inputAction)
  self.dt = dt
  if not lightinit then self:updateLighting(false, dt or 0) lightinit = true end

  -- if our scheduler is not initialized we need to populate it first
  if not initialized then
    for actor in self:eachActor(components.Controller, components.Aicontroller) do
      self.scheduler:add(actor)
    end

    -- we add a special tick to the scheduler that's used for durations and
    -- damage over time effects
    self.scheduler:add("tick")

    initialized = true
  end

  -- if we are waiting for an actor we check if we got an action if not we keep
  -- on waiting
  if waitingFor then
    if inputAction then
      self:performAction(inputAction)
      waitingFor = nil
      return nil
    else
      return waitingFor
    end
  end

  while true do
    -- check if we should quit before we move onto the next actor
    if self.shouldQuit then return love.event.push('quit') end

    -- grab the next actor off the scheduler
    local actor = self.scheduler:next()

    if actor == "tick" then
      -- We found the special actor tick which triggers recurring condition effects
      -- like damage over time. It's also used to track durations.
      self.scheduler:addTime(actor, 100)
      self:triggerActionEvents("onTicks")
    else
      self:updateFOV(actor)

      -- if we find a player controlled actor we set waitingFor and return it
      -- this hands things off to the interface which generates a command for
      -- the actor
      if actor.inputControlled then
        waitingFor = actor
        return waitingFor
      end

      -- if we don't have a player controlled actor we ask the actor for it's
      -- next action through it's controller

      -- TODO: don't provide act with level
      local action = actor:act(self)
      assert(not (action == nil))
      self:performAction(action)
      -- we continue to the next actor
    end
  end
end

function Level:getCell(x, y)
  if self.map[x] then
    return self.map[x][y]
  end

  return nil
end

function Level:updateFOV(actor)
  actor.seenActors = {}

  -- check if actor.fov exists and if so we're gonna trash it and start anew
  -- TODO: find a better way to do this that doesn't trash the garbage collector
  if actor.fov then
    actor.fov = {}
    self.fov:compute(actor.position.x, actor.position.y, actor.sight, self:getFOVCallback(actor))
    self:updateSeenActors(actor)
    self:updateScryActors(actor)
  end
end

local function cmul(col, scalar)
  return {col[1] * scalar, col[2] * scalar, col[3] * scalar}
end

local lightinit = false
function Level:updateLighting(effect, dt)
  for actor in self:eachActor(components.Light) do
    local x, y = actor.position.x, actor.position.y

    local light
    -- Check if we should be manipulating the light with lightingEffects
    -- like flickering or pulsing.
    if actor.lightEffect and effect then
      light = cmul(actor.lightEffect(dt), actor.lightIntensity)
    else
      light = cmul(actor.light, actor.lightIntensity)
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

  local lightsToClean = {}
  local stopIndex = 1

  if #self.temporaryLights > 0 then
    for i = #self.temporaryLights, 1 do
      local light = self.temporaryLights[i]
      local x, y, color = light(dt)

      if not color then table.remove(self.temporaryLights, i) end

      table.insert(lightsToClean, {x, y})
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
  for actor in self:eachActor(components.Light) do
      self.lighting:setLight(actor.position.x, actor.position.y, nil)
  end

  for _, light in ipairs(lightsToClean) do
    self.lighting:setLight(light[1], light[2], nil)
  end
end

function Level:updateEffectLighting(dt)
  self:updateLighting(true, dt)
end

function Level:addEffect(effect)
  -- we push the effect onto the effects stack and then the interface
  -- resolves these
  table.insert(self.effects, 1, effect)
end

function Level:invalidateLighting(actor)
  if actor and not actor.blocksVision then return end

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
      local scryedActor = event:fire(condition, self, actor)

      if scryedActor then
        scryed[scryedActor] = true
      end
    end
  end

  for scryActor, _ in pairs(scryed) do
    table.insert(actor.scryActors, scryActor)
  end
end

function Level:updateSeenActors(actor)
  actor.seenActors = {}

  for k, other in ipairs(self.actors) do
    if (other:isVisible() or actor == other) and
    actor.fov[other.position.x] and
    actor.fov[other.position.x][other.position.y]
    then
      table.insert(actor.seenActors, other)
    end
  end
end


function Level:addActor(actor)
  table.insert(self.actors, actor)

  if initialized and actor:hasComponent(components.Controller, components.Aicontroller) then
    self.scheduler:add(actor)
  end

  if actor:hasComponent(components.Sight) then
    self:updateFOV(actor)
  end
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
    if self.actors[i]:is(type)then
      return self.actors[i]
    end
  end
end

function Level:removeActor(actor)
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

  -- We check to make sure there is a player controlled actor left.
  self:checkLoseCondition()
end

function Level:destroyActor(actor)
  for invActor in self:eachActor() do
    if invActor:hasComponent(components.Inventory) then
      local hasItem = invActor:hasItem(actor)
      if hasItem then
        self:addActor(actor)
        table.remove(invActor.inventory, hasItem)
      end
    end
  end

  self:removeActor(actor)

  if actor.blocksVision then
    self:invalidateLighting()
  end
end

function Level:checkLoseCondition()
  local foundPlayerActor = false

  for i, v in ipairs(self.actors) do
    foundPlayerActor = foundPlayerActor or v.inputControlled
  end

  -- set the shouldQuit flag which will be checked in Level.update
  self.shouldQuit = not foundPlayerActor
end

function Level:moveActor(actor, pos)
  -- if this actor exists in another actor's inventory we first remove the item
  -- from their inventory, and then add it to the level.
  for invActor in self:eachActor(components.Inventory) do
    local hasItem = invActor:hasItem(actor)
    if hasItem then
      self:addActor(actor)
      table.remove(invActor.inventory, hasItem)
    end
  end

  -- we copy the position here so that the caller doesn't have to worry about
  -- allocating a new table
  actor.position = pos:copy()

  if actor:hasComponent(components.Sight) then
    self:updateFOV(actor)
  end

  if actor.blocksVision then
    self.lighting:setFOV(self.fov)
  end

  if actor.light or actor.blocksVision then
    self:updateLighting(false, self.dt)
  end

  for seen in self:eachActor(components.Sight) do
    self:updateSeenActors(seen)
  end
end

function Level:performAction(action, free)
  self:triggerActionEvents("onActions", action)

  self:addMessage(action)
  action:perform(self)

  self:triggerActionEvents("afterActions", action)

  -- if this isn't a reaction or free action and the level contains the acting actor
  -- we update it's place in the scheduler
  if not action.reaction and not free and self:hasActor(action.owner) then
    self.scheduler:addTime(action.owner, action.time)
  end
end

local dummy = {} -- just to avoid making garbage
function Level:triggerActionEvents(type, action)
  if type == "onTicks" then
    for _, actor in ipairs(self.actors) do
      for i, condition in ipairs(actor:getConditions()) do
        local e = condition:getActionEvents(type, self) or dummy
        for i, event in ipairs(e) do
          event:fire(condition, self, actor)
        end
      end
    end

    return
  end

  if not action then return nil end

  for k, condition in ipairs(action.owner:getConditions()) do
    local e = condition:getActionEvents(type, self, action)
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
        local e = condition:getActionEvents(type, self, action)
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
  if type == "fov" then
    local fov = {}
    local seenActors = {}
    self.fov:compute(position.x, position.y, range, self:getAOEFOVCallback(fov))
    for k, other in ipairs(self.actors) do
      if fov[other.position.x] and
      fov[other.position.x][other.position.y]
      then
        table.insert(seenActors, other)
      end
    end

    return fov, seenActors
  end
end

function Level:addMessage(message, actor)
  -- if they specified an actor we check if they have a message component and
  -- send them and specifically them that message
  if actor and actor:hasComponent(components.Message) then
    table.insert(actor.messages, message)
    return
  end

  -- if actor wasn't specified we send the message to each actor who can see the
  -- message's owner and has a message component
  for actor in self:eachActor(components.Message) do
    if actor:hasComponent(components.Sight) then
      for k, v in ipairs(actor.seenActors) do
        if v == message.owner then
          table.insert(actor.messages, message)
        end
      end
    else
      table.insert(actor.messages, message)
    end
  end
end

function Level:eachActor(...)
  local n = 1
  local comp = {...}
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

function Level:getCellPassable(x, y)
  if not (self:getCell(x, y) == 0) then
    return false
  else
    for actor in self:eachActor() do
      if actor.position.x == x and actor.position.y == y and actor.passable == false then
        return false
      end
    end

    return true
  end
end

function Level:getCellPass(x, y)
  return self:getCell(x, y) == 0
end

function Level:getCellVisibility(x, y)
  if not (self:getCell(x, y) == 0) then
    return false
  else
    for actor in self:eachActor() do
      if actor.position.x == x and actor.position.y == y and actor.blocksVision == true then
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
    self.map[x][y] = val
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
  self.effectlight = {}

  return function(x, y, color)
    if not self.effectlight[x] then self.effectlight[x] = {} end
    self.effectlight[x][y] = color
  end
end

function Level:getLightReflectivityCallback()
  return function(x, y)
    return self:getCell(x, y) == 0 and 1 or 0
  end
end

function Level:getVisibilityCallback()
  return function(fov, x, y)
    return self:getCellVisibility(x, y)
  end
end

function Level:getFOVCallback(actor)
  return function(x, y, z)
    if actor.explored then
      if not actor.explored[x] then actor.explored[x] = {} end
      actor.explored[x][y] = self:getCell(x, y)
    end

    if not actor.fov[x] then actor.fov[x] = {} end
    actor.fov[x][y] = self:getCell(x, y)
  end
end

function Level:getAOEFOVCallback(aoeFOV)
  return function(x, y, z)
    if self:getCell(x, y) == 1 then return end

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
