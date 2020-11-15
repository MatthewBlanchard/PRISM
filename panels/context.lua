local Panel = require "panel"

local ContextPanel = Panel:extend()
ContextPanel.interceptInput = true

function ContextPanel:__new(display, parent, target, x, y, w, h)
  Panel.__new(self, display, parent, x, y, w, h)
  self:setTarget(target)
end

function ContextPanel:setTarget(target)
  self.targetActor = target
  self.descHeight = 0
  if self.targetActor and self.targetActor.description then 
    self.descHeight = math.ceil(#self.targetActor.description / (self.w - 2))
  end
  self.h = self:correctHeight(self.descHeight + 3)
end

function ContextPanel:draw()
  self:clear()
  self:drawBorders()

  local w = #self.targetActor.name

  self:write(self:correctWidth(self.targetActor.name, self.w - 2), 2, 2, nil, Panel.backgroundColor)
  self:write(self.targetActor.char, w + 3, 2, self.targetActor.color, Panel.backgroundColor)

  if self.targetActor.description then 
    self:writeText(self.targetActor.description, 2, 3, self.w - 2, nil, Panel.backgroundColor)
  end

  Panel.draw(self)
end

function ContextPanel:handleKeyPress(keypress)
  Panel.handleKeyPress(self, keypress)
end

return ContextPanel
