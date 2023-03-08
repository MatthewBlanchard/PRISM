local Object = require "object"
local Vector2 = require "vector"
local Tiles = require "tiles"

local Panel = require "panel"
local Inventory = require "panels.inventory"
local Status = require "panels.status"
local Message = require "panels.message"

local Interface = Panel()

function Interface:__new(display)
  Panel.__new(self, display)
  self.statusPanel = Status(display)
  self.messagePanel = Message(display)
  self.defaultBackgroundColor = display.defaultBackgroundColor
  self.stack = {}
  self.t = 0
end

function Interface:update(dt)
  self.t = (self.t + dt) % 0.600
  self.dt = dt
  self.messagePanel:update(dt)

  local lighting = game.level:getSystem("lighting")
  if lighting then
    lighting:rebuildLighting(game.level, dt)
  end

  if not self:peek() then return end
  self:peek():update(dt)
end

local function value(c)
  return (c[1] + c[2] + c[3]) / 3
end

local function clerp(start, finish, t)
  local c = {}
  for i = 1, 4 do
    if not start[i] or not finish[i] then break end
    c[i] = (1 - t) * start[i] + t * finish[i]
  end

  return c
end

local function cmul(c1, s)
  return { c1[1] * s, c1[2] * s, c1[3] * s }
end

local function cadd(c1, c2)
  return { c1[1] + c2[1], c1[2] + c2[2], c1[3] + c2[3] }
end

local function csub(c1, c2)
  return { c1[1] - c2[1], c1[2] - c2[2], c1[3] - c2[3] }
end

local function shouldDrawExplored(explored, x, y)
  if explored[x] and explored[x][y] == 0 then return true end

  for i = -1, 1 do
    for j = -1, 1 do
      if explored[x + i] then
        if explored[x + i][y + j] == 0 then
          return true
        end
      end
    end
  end
end

local ambientColor = { .175, .175, .175 }
function Interface:draw()
  local sight_component = game.curActor:getComponent(components.Sight)
  local fov = sight_component.fov
  local explored = sight_component.explored
  local seenActors = sight_component.seenActors
  local scryActors = sight_component.scryActors

  local lighting_system = game.level:getSystem("Lighting")
  local light = lighting_system.__lightMap
  local ambientValue = sight_component.darkvision

  local viewX, viewY = game.viewDisplay.widthInChars, game.viewDisplay.heightInChars
  local sx, sy = game.curActor.position.x, game.curActor.position.y
  for x = sx - viewX, sx + viewX do
    for y = sy - viewY, sy + viewY do
      if fov[x] and fov[x][y] then
        local lightCol = lighting_system:getLightingAt(x, y, fov, light)
        if lightCol then
          -- okay we're gonna first establish our light color and then
          -- do a bit of blending to keep it in line with the ambient
          -- fog of war
          local finalColor
          local lightValue = math.min(value(lightCol), 1)

          local t = math.min(1, math.max(lightValue - ambientValue, 0))
          t = math.min(t / (1 - ambientValue), 1)
          finalColor = clerp(ambientColor, lightCol, t)

          if lightValue ~= lightValue then finalColor = ambientColor end
          self:writeOffset(fov[x][y].tile, x, y, finalColor)
        else
          self:writeOffset(fov[x][y].tile, x, y, ambientColor)
        end
      elseif explored[x] and explored[x][y] then
        self:writeOffset(explored[x][y].tile, x, y, ambientColor)
      end
    end
  end

  local function getAnimationChar(actor)
    if not actor:hasComponent(components.Animated) then return actor.char end
    if self.t > 0.400 then
      return actor.char + 16
    end

    return actor.char
  end

  local distortion = false
  for k, actor in pairs(seenActors) do
    if actor:hasComponent(components.Realitydistortion) then
      distortion = true
    end
  end

  if distortion then
    game.music:startDistortion()
  else
    game.music:endDistortion()
  end

  local function drawActors(actorTable, conditional)
    for k, actor in pairs(actorTable) do
      local char = getAnimationChar(actor)
      if conditional and conditional(actor) or true then
        local x, y = actor.position.x, actor.position.y
        if actorTable ~= scryActors and light[x] and light[x][y] then
          local lightCol = lighting_system:getLightingAt(x, y, fov, light)
          local lightValue = value(lightCol)
          local t = math.max(lightValue - ambientValue, 0)
          t = math.min(t / (1 - ambientValue), 1)
          local finalColor = clerp(ambientColor, lightCol, t)
          self:writeOffset(char, x, y, clerp(ambientColor, actor.color, t))
        else
          self:writeOffset(char, x, y, ambientColor)
        end
      end
    end
  end

  drawActors(scryActors)

  -- draw things that don't move furst
  drawActors(seenActors,
    function(actor)
      return not actor:hasComponent(components.Move)
    end
  )

  -- next up draw things that move but don't block movement
  drawActors(seenActors,
    function(actor)
      return actor:hasComponent(components.Move) and actor.passable
    end
  )

  -- now we draw the stuff that moves and blocks movement
  drawActors(seenActors,
    function(actor)
      return actor:hasComponent(components.Move) and not actor.passable
    end
  )

  drawActors({game.curActor}, function ()
    return true
  end)

  local effect_system = game.level:getSystem("Effects")
  if not self.animating then
    effect_system.effects = {}
  end

  if #effect_system.effects ~= 0 then
    for i = #effect_system.effects, 1, -1 do
      local curEffect = effect_system.effects[i]
      self._curEffectDone = true
      local done = curEffect(self.dt, self) or self._curEffectDone

      if done then
        table.remove(effect_system.effects, i)
      end
    end
  end

  self.statusPanel:draw()
  self.messagePanel:draw()

  if not self:peek() then return end
  self:peek():draw()
end

Interface.movementTranslation = {
  -- cardinal
  w = Vector2(0, -1),
  s = Vector2(0, 1),
  a = Vector2(-1, 0),
  d = Vector2(1, 0),

  -- diagonal disable these and change the target in the Move action
  -- if you want to disable diagonal movement
  q = Vector2(-1, -1),
  e = Vector2(1, -1),
  z = Vector2(-1, 1),
  c = Vector2(1, 1)
}

Interface.keybinds = {
  ["tab"] = "inventory",
  p = "pickup",
  l = "log",
  m = "map"
}

function Interface:clearEffects()
end

function Interface:handleKeyPress(keypress)
  if self:peek() then
    self:peek():handleKeyPress(keypress)
    return nil
  end

  if game.curActor:hasComponent(components.Inventory) then
    if self.keybinds[keypress] == "inventory" then
      self:push(Inventory(self.display, self))
    end

    if self.keybinds[keypress] == "log" then
      self.messagePanel:toggleHeight()
    end

    if self.keybinds[keypress] == "pickup" then
      local sight_component = game.curActor:getComponent(components.Sight)
      local item
      for k, i in pairs(sight_component.seenActors) do
        if actions.Pickup:validateTarget(1, game.curActor, i) then
          return self:setAction(game.curActor:getAction(actions.Pickup)(game.curActor, {i}))
        end
      end
    end

    if self.keybinds[keypress] == "map" then
      game.viewDisplay = game.viewDisplay == game.viewDisplay1x and game.viewDisplay2x or game.viewDisplay1x
    end
  end

  -- we're dealing with a directional command here
  if self.movementTranslation[keypress] and game.curActor:hasComponent(components.Move) then
    local targetPosition = game.curActor.position + self.movementTranslation[keypress]

    local sight_component = game.curActor:getComponent(components.Sight)
    local enemy
    for k, actor in pairs(sight_component.seenActors) do
      if actor.position == targetPosition then
        enemy = actor
      end
    end

    if enemy then
      if enemy:hasComponent(components.Usable) and
          enemy.defaultUseAction and
          enemy.defaultUseAction:validateTarget(1, game.curActor, enemy) and
          not love.keyboard.isDown("lctrl")
      then
        if not enemy.passable or love.keyboard.isDown("lshift") then
          return self:setAction(enemy.defaultUseAction(game.curActor, { enemy }))
        end
      end

      if enemy:hasComponent(components.Stats) then
        if not enemy.passable or love.keyboard.isDown("lctrl") then
          return self:setAction(game.curActor:getAction(actions.Attack)(game.curActor, enemy))
        end
      end
    end

    return self:setAction(game.curActor:getAction(actions.Move)(game.curActor, self.movementTranslation[keypress]))
  end
end

function Interface:setAction(action)
  self.action = action
end

function Interface:getAction()
  local action = self.action
  self.action = nil
  return action
end

function Interface:push(panel)
  table.insert(self.stack, panel)
end

function Interface:pop()
  local panel = self.stack[#self.stack]
  self.stack[#self.stack] = nil
  return panel
end

function Interface:peek()
  return self.stack[#self.stack]
end

function Interface:reset()
  for i = 1, #self.stack do
    self.stack[i] = nil
  end
end

return Interface
