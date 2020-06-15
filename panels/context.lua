local Panel = require "panel"
local Selector = require "panels.selector"

local ContextPanel = Panel:extend()
ContextPanel.interceptInput = true

function ContextPanel:__new(display, parent, target)
  Panel.__new(self, display, parent, 1, 1, display:getWidth(), display:getHeight())
  self.targetActor = target
end

function ContextPanel:draw()
  self.allowedAction = {}

  if self.targetActor:hasComponent(components.Usable) then
    for k, action in pairs(self.targetActor.useActions) do
      if action:getNumTargets() > 0 and action:validateTarget(1, game.curActor, self.targetActor) then
        table.insert(self.allowedAction, action)
      end
    end
  end

  for k, action in pairs(game.curActor.actions) do
    if action:getNumTargets() > 0 and action:validateTarget(1, game.curActor, self.targetActor) and not action:is(actions.Attack) then
      table.insert(self.allowedAction, action)
    end
  end

  for i = 1, #self.allowedAction do
    self.display:write(i .. " - " .. self.allowedAction[i].name, 1, i)
  end

  Panel.draw(self)
end

function ContextPanel:handleKeyPress(keypress)
  Panel.handleKeyPress(self, keypress)

  local chosenAction = self.allowedAction[tonumber(keypress)]
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
