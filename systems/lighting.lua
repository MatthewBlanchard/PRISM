local System = require "system"
local SparseMap = require "sparsemap"

-- TODO: Rip out the current lighting system and do something more similar to Minecraft's
-- simple lighting system but with 3 channels r,g,b each consisting of an integer from 0-31.
local LightingSystem = System:extend()
LightingSystem.name = "Lighting"

LightingSystem.__lights = nil
LightingSystem.__lightMap = nil
LightingSystem.__temporaryLights = nil

function LightingSystem:__new()
    self.__lights = SparseMap()
    self.__lightMap = {}
    self.__effectLightMap = {}
    self.__temporaryLights = {}
    self.__opaqueCache = {}
end

function LightingSystem:initialize(level)
  self.__fov = ROT.FOV.Recursive(self:createVisibilityClosure(level))
  self.lighting = ROT.Lighting(self:getLightReflectivityCallback(), { range = 50, passes = 3 })
  self.lighting:setFOV(self.__fov)
  self:rebuildLighting(level)
end

function LightingSystem:beforeAction(level, actor, action)
  for actor in level:eachActor() do
    self.__opaqueCache[actor] = actor.blocksVision
  end
end
-- called when an Actor takes an Action 
function LightingSystem:afterAction(level, actor, action)
  local force_rebuild = false
  for actor in level:eachActor() do
    if self.__opaqueCache[actor] ~= actor.blocksVision then
      force_rebuild = true
    end
    self.__opaqueCache[actor] = nil
  end

  if force_rebuild then
    self:forceRebuildLighting(level)
  else
    self:rebuildLighting(level)
  end
end

-- called after an actor has moved
function LightingSystem:onMove(level, actor)
  self:rebuildLighting(level)
end

function LightingSystem:onActorAdded(level, actor)
  self:rebuildLighting(level)
end

function LightingSystem:onActorRemoved(level, actor)
  self:rebuildLighting(level)
end

function LightingSystem:invalidateLighting(level)
  if not self.light or not self.lighting.setFOV then return end -- check if lighting is initialized

  -- This resets our lighting. rotLove doesn't offer a better way to do this.
  self:updateLighting(false)
end

--- Creates a list of all of the light components in the level and returns it.
function LightingSystem:__buildLightList(level)
  local lights = SparseMap()

  for light_actor in level:eachActor(components.Light) do
    local light_component = light_actor:getComponent(components.Light)
    local x, y = light_actor.position.x, light_actor.position.y

    lights:insert(x, y, light_component)
  end

  for _, system in ipairs(level.systems) do
    if system.registerLights then
      -- Systems can register their own lights by implementing a registerLights function
      -- TODO: move from actors with light components to a system that registers lights 
      -- directly with the lighting system.
      for _, light_tuple in ipairs(system:registerLights(level)) do
        local light_component = light_tuple[3]
        local x, y = light_tuple[1], light_tuple[2]

        lights:insert(x, y, light_component)
      end
    end
  end

  return lights
end

function LightingSystem:__checkLightList(candidate)
  local candidate_count = candidate:count()
  local light_count = self.__lights:count()

  if candidate_count ~= light_count then
    return false
  end

  for x, y, candidate_cell in candidate:each() do
    if not self.__lights:has(x, y, candidate_cell) then
      return false
    end
  end

  return true
end

local function cmul(col, scalar)
  return { col[1] * scalar, col[2] * scalar, col[3] * scalar }
end

function LightingSystem:rebuildLighting(level, dt)
  local candidate = self:__buildLightList(level)

  -- if our light list hasn't changed, we don't need to rebuild the lighting
  -- looping through the qctors and building a list is way cheaper than rebuilding the lighting
  -- so we do this check first.
  if self:__checkLightList(candidate) then
    return
  end

  self.__lights = candidate
  self:__rebuild(level, dt)
end

function LightingSystem:forceRebuildLighting(level, dt)
  self.__lights = self:__buildLightList(level)
  self:__rebuild(level, dt)
end

function LightingSystem:__rebuild(level, dt)
  self.lighting = ROT.Lighting(self:getLightReflectivityCallback(), { range = 50, passes = 3 })
  self.lighting:setFOV(self.__fov)
  self.__lightMap = {}

  for x, y, light_component in self.__lights:each() do
    assert(light_component.is and light_component:is(components.Light))
    local light
    -- Check if we should be manipulating the light with lightingEffects
    -- like flickering or pulsing.
    if light_component.effect and dt then
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

  local lightsToClean = {}

  if dt and #self.__temporaryLights > 0 then
    for i = #self.__temporaryLights, 1, -1 do
      local light = self.__temporaryLights[i]
      local x, y, color = light(dt)

      if not color then table.remove(self.__temporaryLights, i) end

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
  local callback = dt and self:getLightingEffectCallback() or self:getLightingCallback()
  self.lighting:compute(callback)
end

function LightingSystem:at(x, y)
  return self.__lightMap[x] and self.__lightMap[x][y]
end

-- Takes a fov because wall lighting uses the fov to determine how to light the walls
function LightingSystem:getLightingAt(x, y, fov)
  local light = self.__lightMap
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


function LightingSystem:getLightingCallback()
  self.light = {}

  return function(x, y, color)
    if not self.__lightMap[x] then self.__lightMap[x] = {} end
    self.__lightMap[x][y] = color
  end
end

function LightingSystem:getLightingEffectCallback()
  return function(x, y, color)
    if not self.__effectLightMap[x] then self.__effectLightMap[x] = {} end
    self.__effectLightMap[x][y] = color
  end
end

function LightingSystem:getLightReflectivityCallback()
  return function(lighting, x, y)
    return 0
  end
end

-- Little factories for some callback functions we need to pass to the FOV calculator
function LightingSystem:createVisibilityClosure(level)
  return function(fov, x, y)
      return level:getCellVisibility(x, y)
  end
end

return LightingSystem