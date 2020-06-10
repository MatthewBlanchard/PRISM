local Object = require "object"

local Level = Object:extend()

function Level:__new(map)
  self.map = {}
  self.width = map._width
  self.height = map._height

  self.light = {}
  self.actors = {}
  self.effects = {}

  self.scheduler = ROT.Scheduler.Simple:new()

  self.fov = ROT.FOV.Recursive(self:getVisibilityCallback())

  self.lighting = ROT.Lighting(self:getLightReflectivityCallback(), {range = 20, passes = 3})
  self.lighting:setFOV(self.fov)

  map:create(self:getMapCallback())

  if not map._doors then return end
  for k, d in pairs(map._doors) do
    local door = actors.Door()
    door.position.x = d.x
    door.position.y = d.y

    self:addActor(door)
  end
end

local initialized
local waitingFor
function Level:update(dt, inputAction)
  if not lightinit then self:updateLighting(false, dt or 0) lightinit = true end

  -- if our scheduler is not initialized we need to populate it first
  if not initialized then
    for actor in self:eachActor(components.Controller, components.Aicontroller) do
      self.scheduler:add(actor)
    end

    initialized = true
  end

  if waitingFor then
    if inputAction then
      self:performAction(inputAction)
      self:updateLighting(false, dt)
      waitingFor = nil
      return nil
    else
      return waitingFor
    end
  end

  while true do
    local actor = self.scheduler:next()
    self:updateFOV(actor)

    if actor.inputControlled then
      waitingFor = actor
      return waitingFor
    end

    local action = actor:act()
    assert(not (action == nil))
    self:performAction(action)
    self:updateLighting(false, dt)
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

  if actor.fov then
    actor.fov = {}
    self.fov:compute(actor.position.x, actor.position.y, actor.sight, self:getFOVCallback(actor))
    self:updateSeenActors(actor)
  end
end

local function cmul(col, scalar)
  return {col[1] * scalar, col[2] * scalar, col[3] * scalar}
end

local lightinit = false
function Level:updateLighting(effect, dt)
  self.light = {}

  for k, actor in pairs(self.actors) do
    if actor:hasComponent(components.Light) then
      local x, y = actor.position.x, actor.position.y

      local light
      if actor.lightEffect then
        light = cmul(actor.lightEffect(dt), actor.lightIntensity)
      else
        light = cmul(actor.light, actor.lightIntensity)
      end

      local curLight = self.lighting:getLight(x, y)
      if curLight then
        self.lighting:setLight(x, y, ROT.Color.add(light, curLight))
      else
        self.lighting:setLight(x, y, light)
      end
    end
  end

  if effect then
    self.lighting:compute(self:getLightingEffectCallback())
  else
    self.lighting:compute(self:getLightingCallback())
  end

  for k, actor in pairs(self.actors) do
    if actor:hasComponent(components.Light) then
      self.lighting:setLight(actor.position.x, actor.position.y, nil)
    end
  end
end

function Level:updateEffectLighting(dt)
  self:updateLighting(true, dt)
end

function Level:addEffect(effect)
  table.insert(self.effects, effect)
end

function Level:invalidateLighting()
  self.lighting:setFOV(self.fov)
end

function Level:updateSeenActors(actor)
  actor.seenActors = {}

  for k, other in pairs(self.actors) do
    if actor.fov[other.position.x] and actor.fov[other.position.x][other.position.y] then
      table.insert(actor.seenActors, other)
    end
  end
end


function Level:addActor(actor)
  table.insert(self.actors, actor)

  if initialized and actor:hasComponent(components.Controller, components.Aicontroller) then
    self.scheduler:add(actor)
  end
end

function Level:hasActor(actor)
  for i = 1, #self.actors do
    if self.actors[i] == actor then
      return i
    end
  end
end

function Level:removeActor(actor)
  for k, v in pairs(self.actors) do
    if v == actor then
      table.remove(self.actors, k)
    end
  end

  if initialized then --and actor:hasComponent(components.Controller, components.Aicontroller) then
    self.scheduler:remove(actor)
  end

  for actor in self:eachActor(components.Sight) do
    self:updateFOV(actor)
  end


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

  if actor.blocksVision then
    self:invalidateLighting()
  end

  self:removeActor(actor)
end

function Level:moveActor(actor, pos)
  for invActor in self:eachActor() do
    if invActor:hasComponent(components.Inventory) then
      local hasItem = invActor:hasItem(actor)
      if hasItem then
        self:addActor(actor)
        table.remove(invActor.inventory, hasItem)
      end
    end
  end

  actor.position = pos:copy()

  self:updateFOV(actor)

  if actor.blocksVision then
    self.lighting:setFOV(self.fov)
  end

  for seen in self:eachActor(components.Sight) do
    self:updateSeenActors(seen)
  end
end

function Level:performAction(action)
  self:triggerActionEvents("onActions", action)

  self:addMessage(action)
  action:perform(self)

  self:triggerActionEvents("afterActions", action)

  if not action.reaction and self:hasActor(action.owner) then
    self.scheduler:add(action.owner)
  end
end

function Level:triggerActionEvents(type, action)
  for k, condition in pairs(action.owner:getConditions()) do
    local e = condition:getActionEvents(type, self, action)
    if e then
      for k, event in pairs(e) do
        e:fire(self, action)
      end
    end
  end

  if not action:getTargets() then return end

  for k, actor in pairs(action:getTargets()) do
    for k, condition in pairs(actor:getConditions()) do
      local e = condition:getActionEvents(type, self, action)
      if e then
        for k, event in pairs(e) do
          event:fire(self, action)
        end
      end
    end
  end
end

function Level:addMessage(message)
  for actor in self:eachActor(components.Message) do
    if actor:hasComponent(components.Sight) then
      for k, v in pairs(actor.seenActors) do
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

function Level:getRandomWalkableTile()
  while true do
    local x, y = ROT.RNG:random(1, self.width), ROT.RNG:random(1, self.height)
    if self:getCellPassable(x, y) then
      return x, y
    end
  end
end


return Level
