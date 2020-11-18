local Panel = require "panel"
local ContextPanel = require "panels.context"
local Vector = require "vector"
local Bresenham = require "bresenham"

local function bresenhamCallback(x, y)
  return game.level:getCellPass(x, y)
end

local function blink(period)
  local t = 0
  return function(dt)
    t = t + dt
    if t < period then
      return true
    elseif t > period * 2 then
      t = t - period * 2
      return false
    elseif t > period then
      return false
    end
  end
end

local SelectorPanel = Panel:extend()
SelectorPanel.interceptInput = true
SelectorPanel.blinkColor = {0.2, 0.2, 0.6, 1}
SelectorPanel.invalidColor = {0.6, 0, 0, 1}
SelectorPanel.lineColor = {0.5, 0.5, 0.5}

function SelectorPanel:__new(display, parent, action, targets)
  Panel.__new(self, display, parent, 1, 1, display:getWidth(), display:getHeight())
  self.action = action
  self.blinkFunc = blink(0.3)
  self.targets = targets or {}
  self.movementTranslation = self:getRoot().movementTranslation
  -- Where the cursor is pointing
  self.curTarget = nil

  -- Index in the getValidTargets() array
  self.targetIndex = nil

  self.line = {}
  self.valid = true

  self.targetPanel = ContextPanel(self.display, self, nil, 52, 12, 29, 11)
end

function SelectorPanel:draw()
  local position = self:getTargetPosition()
  if not self.blink then
    self:writeOffset("X", position.x, position.y, self.valid and SelectorPanel.blinkColor or SelectorPanel.invalidColor)
  end

  if self.curTarget.name then
    local last = self.line[#self.line == 1 and 1 or #self.line - 1]
    local x = position.x + 2
    local y = position.y

    if last[2] == position.y then
      y = position.y - 1
      x = position.x - math.floor(#self.curTarget.name / 2)
    elseif last[1] > position.x then
      x = position.x - 1 - #self.curTarget.name
    end

    self:writeOffset(self.curTarget.name, x, y)
  end

  if self.valid then
    for i = 2, #self.line - 1 do
      self:writeOffset("x", self.line[i][1], self.line[i][2], SelectorPanel.lineColor)
    end
  end

  if self.curTarget.name then
    self.targetPanel:draw()
  end
end

function SelectorPanel:getTargetPosition()
  if self.curTarget then
    return self.curTarget.position or self.curTarget
  elseif self.action:getTargetObject(#self.targets + 1):is(targets.Point) then
    self.curTarget = game.curActor.position
    return game.curActor.position
  else
    self.targetIndex = 1
    self.targetPanel:setTarget(game.curActor)
    self.curTarget = Vector(game.curActor.position.x, game.curActor.position.y)
    return self.curTarget
  end
end

function SelectorPanel:update(dt)
  self.blink = self.blinkFunc(dt)
end

function SelectorPanel:tabTarget(actor)
  local n = 1
  local currentTarget = #self.targets + 1
  local valid = self:getValidTargets(currentTarget)

  if #valid < 1 then
    game.interface:reset()
    return
  end

  if self.targetIndex then
    -- If player is holding shift, go back a target
    if love.keyboard.isDown("lshift") then
      if self.targetIndex == 1 then
        n = #valid
      else
        n = self.targetIndex - 1
      end
    else
      if self.targetIndex + 1 > #valid then
        n = 1
      else
        n = self.targetIndex + 1
      end
    end
  end

  self.targetIndex = n
  self:updateTarget(valid[n])
end

function SelectorPanel:updateTarget(target)
  self.curTarget = target
  self.targetPanel:setTarget(self.curTarget)
  local line, valid = Bresenham.line(game.curActor.position.x, game.curActor.position.y, self:getTargetPosition().x, self:getTargetPosition().y, bresenhamCallback)
  self.line = line
  self.valid = valid
end

function SelectorPanel:moveTarget(direction)
  local position = self:getTargetPosition() + direction
  local valid = self:getValidTargets(#self.targets + 1)

  -- check if the new position lands on a valid actor
  for i = 1, #valid do
    if position == valid[i].position then
      self:updateTarget(valid[i])
      return
    end
  end

  -- if not, just set to position
  self:updateTarget(position)
end

function SelectorPanel:getValidTargets(index)
  local targets = {}

  if self.action.targets[index]:is(targets.Point) then
    return game.curActor.seenActors
  end

  for i = 1, #game.curActor.seenActors do
    if self.action:validateTarget(index, game.curActor, game.curActor.seenActors[i]) then
      local isTargeted = false

      for j = 1, #self.targets do
        isTargeted = self.targets[j] == game.curActor.seenActors[i]
        if isTargeted then
          break
        end
      end

      if not isTargeted then
        table.insert(targets, game.curActor.seenActors[i])
      end
    end
  end

  return targets
end

function SelectorPanel:handleKeyPress(keypress)
  Panel.handleKeyPress(self, keypress)

  if keypress == "tab" then
    self:tabTarget(self.curActor)
  elseif self.action.targets[#self.targets + 1]:is(targets.Point) and self.movementTranslation[keypress] then
    self:moveTarget(self.movementTranslation[keypress])
  elseif keypress == "return" and self.valid then
    if  self.action.targets[#self.targets + 1]:is(targets.Point) and
        self.action:validateTarget(#self.targets + 1, game.curActor, self.curTarget)     then
      table.insert(self.targets, self.curTarget.position or self.curTarget)
    else
      table.insert(self.targets, self.curTarget)
    end
    self.targetIndex = nil

    if #self.targets == self.action:getNumTargets() then
      game.interface:reset()
      game.interface:setAction(self.action(game.curActor, self.targets))
    end
  end
end

return SelectorPanel
