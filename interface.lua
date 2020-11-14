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
  self.stack = {}
end

function Interface:update(dt)
  self.dt = dt
  self.messagePanel:update(dt)
  game.level:updateEffectLighting(dt)

  if #game.level.effects > 0 and not self.curEffect then
    self.curEffect = table.remove(game.level.effects, 1)
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
  return {c1[1] * s, c1[2] * s, c1[3] * s}
end

local function cadd(c1, c2)
  return {c1[1] + c2[1], c1[2] + c2[2], c1[3] + c2[3]}
end


local function csub(c1, c2)
  return {c1[1] - c2[1], c1[2] - c2[2], c1[3] - c2[3]}
end

local function shouldDrawExplored(explored, x, y)
  if explored[x] and explored[x][y] == 0 then return true end

  for i = -1, 1 do
    for j = -1, 1 do
      if explored[x+i] then
        if explored[x+i][y+j] == 0 then
          return true
        end
      end
    end
  end
end

local function calculateLight(x, y, fov, light)
  if fov[x][y] == 0 then return light[x][y] end

  local finalCol = { 0, 0, 0 }
  local cols = {}

  for i = -1, 1, 1 do
    for j = -1, 1, 1 do
      if fov[x+i] and fov[x+i][y+j] and fov[x+i][y+j] == 0 then
        table.insert(cols, light[x+i][y+j])
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

function Interface:draw()
  local fov = game.curActor.fov
  local explored = game.curActor.explored
  local seenActors = game.curActor.seenActors
  local scryActors = game.curActor.scryActors
  local light = game.level.effectlight
  local ambientColor = {.175, .175, .175}

  local viewX, viewY = game.viewDisplay.widthInChars, game.viewDisplay.heightInChars
  local sx, sy = game.curActor.position.x, game.curActor.position.y
  for x = sx - viewX, sx + viewX do
    for y = sy - viewY, sy + viewY do
      if fov[x] and fov[x][y] then
        if light[x] and light[x][y] then
          -- okay we're gonna first establish our light color and then
          -- do a bit of blending to keep it in line with the ambient
          -- fog of war
          local finalColor
          local lightCol = calculateLight(x, y, fov, light)
          local lightValue = value(lightCol)
          local ambientValue = value({.175, .375, .175})

          if lightValue < ambientValue then
            local t = 1 - lightValue / ambientValue
            finalColor = clerp(lightCol, ambientColor, t)
          else
            finalColor = lightCol
          end
          self:writeOffset(fov[x][y] == 0 and Tiles["floor"] or Tiles["wall"], x, y, finalColor)
        else
          self:writeOffset(fov[x][y] == 0 and Tiles["floor"] or Tiles["wall"], x, y, ambientColor)
        end
      elseif explored[x] and explored[x][y] and shouldDrawExplored(explored, x, y) then
        self:writeOffset(explored[x][y] == 0 and Tiles["floor"] or Tiles["wall"], x, y, ambientColor)
      end
    end
  end

  for k, actor in pairs(scryActors) do
    local x, y = actor.position.x, actor.position.y
    self:writeOffset(actor.char, x, y, actor.color)
  end

  for k, actor in pairs(seenActors) do
    if not actor:hasComponent(components.Move) then
      local x, y = actor.position.x, actor.position.y
      if light[x] and light[x][y] then
        local lightValue = math.min(value(light[x][y]), 0.5)
        self:writeOffset(actor.char, x, y, clerp(ambientColor, actor.color, lightValue / 0.5))
      end
    end
  end

  for k, actor in pairs(seenActors) do
    if actor:hasComponent(components.Move) then
      local x, y = actor.position.x, actor.position.y
      if light[x] and light[x][y] then
        local lightValue = math.min(value(light[x][y]), 0.5)
        self:writeOffset(actor.char, x, y, clerp(ambientColor, actor.color, lightValue / 0.5))
      end
    end
  end

  if self.curEffect then
    self._curEffectDone = true
    local done = self.curEffect(self.dt, self) or self._curEffectDone
    if done then self.curEffect = nil end
  end

  self.statusPanel:draw()
  self.messagePanel:draw()

  if not self:peek() then return end
  self:peek():draw()
end

Interface.movementTranslation = {
  -- cardinal
  w = Vector2(0, - 1),
  s = Vector2(0, 1),
  a = Vector2(-1, 0),
  d = Vector2(1, 0),

  -- diagonal
  q = Vector2(-1, - 1),
  e = Vector2(1, - 1),
  z = Vector2(-1, 1),
  c = Vector2(1, 1)
}

Interface.keybinds = {
  i = "inventory",
  p = "pickup",
  l = "log",
  m = "map"
}

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
      local item
      for k, i in pairs(game.curActor.seenActors) do
        if actions.Pickup:validateTarget(1, game.curActor, i) then
          return self:setAction(game.curActor:getAction(actions.Pickup)(game.curActor, i))
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

    local enemy
    for k, actor in pairs(game.curActor.seenActors) do
      if actor.position == targetPosition then
        enemy = actor
      end
    end

    if enemy then
      if
        enemy:hasComponent(components.Usable) and
        enemy.defaultUseAction and
        enemy.defaultUseAction:validateTarget(1, game.curActor, enemy) and
        not love.keyboard.isDown("lctrl")
      then
        if not enemy.passable or love.keyboard.isDown("lshift") then
          return self:setAction(enemy.defaultUseAction(game.curActor, enemy))
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
  game.level.effects = {}
  game.interface.curEffect = nil
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
