local Panel = require "panel"
local Selector = require "panels.selector"

local ContextPanel = Panel:extend()
ContextPanel.interceptInput = true

function ContextPanel:__new(display, parent, target)
  Panel.__new(self, display, parent, parent.x, parent.y, parent.w, parent.h)
  self.targetActor = target
  self.allowedActions = {}

  if self.targetActor:hasComponent(components.Usable) then
    for k, action in pairs(self.targetActor.useActions) do
      if action:getNumTargets() > 0 and action:validateTarget(1, game.curActor, self.targetActor) then
        table.insert(self.allowedActions, action)
      end
    end
  end

  for k, action in pairs(game.curActor.actions) do
    if action:getNumTargets() > 0 and action:validateTarget(1, game.curActor, self.targetActor) and not action:is(actions.Attack) then
      table.insert(self.allowedActions, action)
    end
  end

  self.descHeight = 0
  if self.targetActor.description then 
    self.descHeight = math.ceil(#self.targetActor.description / (self.w - 2))
  end

  -- Border + name + description + space + actions
  self.h = 4 + self.descHeight + #self.allowedActions
  if self.h % 2 == 0 then 
    self.h = self.h + 1 
  end
end

function ContextPanel:draw()
  self:drawBorders()

  local w = #self.targetActor.name

  self:write(self:correctWidth(self.targetActor.name, self.w - 2), 2, 2, nil, {0.3, 0.3, 0.3, 1})
  self:write(self.targetActor.char, w + 3, 2, self.targetActor.color, {0.3, 0.3, 0.3, 1})

  if self.targetActor.description then 
    self:writeText(self.targetActor.description, 2, 3, self.w - 2)
  end

  for i = 1, #self.allowedActions do
    self:write(i .. " " .. self.allowedActions[i].name, 2, i + self.descHeight + 3)
  end

  Panel.draw(self)
end

function ContextPanel:handleKeyPress(keypress)
  Panel.handleKeyPress(self, keypress)

  local chosenAction = self.allowedActions[tonumber(keypress)]
  if chosenAction then
    if chosenAction:getNumTargets() == 1 then
      game.interface:reset()
      game.interface:setAction(chosenAction(game.curActor, self.targetActor))
    else
      self.currentAction = chosenAction
      game.interface:push(Selector(self.display, self, chosenAction, {self.targetActor}))
    end
  end
end

return ContextPanel
