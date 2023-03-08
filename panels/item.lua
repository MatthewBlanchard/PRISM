local ContextPanel = require "panels.context"
local Selector = require "panels.selector"

local ItemPanel = ContextPanel:extend()

function ItemPanel:__new(display, parent, target, x, y, w, h)
  ContextPanel.__new(self, display, parent, target, x, y, w, h)
  self.allowedActions = {}

  if self.targetActor:hasComponent(components.Usable) then
    for k, action in pairs(self.targetActor.useActions) do
      if action:getNumTargets() > 0 and action:validateTarget(1, game.curActor, self.targetActor) then
        table.insert(self.allowedActions, action)
      end
    end
  end

  for k, action in pairs(game.curActor:getActions()) do
    if action:getNumTargets() > 0 and
        action:validateTarget(1, game.curActor, self.targetActor) and
        not action:is(actions.Attack) then
      table.insert(self.allowedActions, action)
    end
  end

  self.h = self:correctHeight(4 + self.descHeight + #self.allowedActions)
end

function ItemPanel:draw()
  self:clear()
  ContextPanel.draw(self)
  for i = 1, #self.allowedActions do
    self:write(i .. " " .. self.allowedActions[i].name, 2, i + self.descHeight + 3)
  end
end

function ItemPanel:handleKeyPress(keypress)
  ContextPanel.handleKeyPress(self, keypress)

  if #self.allowedActions == 0 then return end

  local chosenAction = self.allowedActions[tonumber(keypress)]
  if chosenAction then
    if chosenAction:getNumTargets() == 1 then
      game.interface:reset()
      game.interface:setAction(chosenAction(game.curActor, {self.targetActor}))
    else
      self.currentAction = chosenAction
      game.interface:push(Selector(self.display, self, chosenAction, { self.targetActor }))
    end
  end
end

return ItemPanel
