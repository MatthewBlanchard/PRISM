local Panel = require "panel"
local ContextPanel = require "panels.context"
local Vector = require "vector"

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
SelectorPanel.blinkColor = {.6, 0, 0, 1}

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

  self.targetPanel = ContextPanel(self.display, self, nil, 52, 12, 29, 11)
end

function SelectorPanel:draw()
  local position = self:getTargetPosition()
  print(position.x, position.y, "YA DUDE")
  if not self.blink then
    self:writeOffset("X", position.x, position.y, SelectorPanel.blinkColor)
  end
  if self.curTarget.name then self:writeOffset(self.curTarget.name, position.x + 2, position.y) end
  self.targetPanel:draw()
end

function SelectorPanel:getTargetPosition()
  return self.curTarget.position or self.curTarget
end

function SelectorPanel:update(dt)
  self.blink = self.blinkFunc(dt)

  if not self.targetIndex then
    self:tabTarget()
  end
end

function SelectorPanel:tabTarget(actor)
  if not self.targetIndex and self.action:getTargetObject(#self.targets + 1):is(targets.Point) then
    self.targetIndex = 1
    self.curTarget = Vector(game.curActor.position.x, game.curActor.position.y)
    self.targetPanel:setTarget(game.curActor)
    return
  end
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
  self.curTarget = valid[n]
  self.targetPanel:setTarget(self.curTarget)
end

function SelectorPanel:moveTarget(direction)
  self.curTarget = self:getTargetPosition() + direction
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
  elseif keypress == "return" then
    if self.action.targets[#self.targets + 1]:is(targets.Point) then
      table.insert(self.targets, self.curTarget.position)
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
