local Panel = require "panel"

local LevelUpPanel = Panel:extend()

function LevelUpPanel:__new(display, parent)
  Panel.__new(self, display, parent, 31, 15, 19, 15)
end

function LevelUpPanel:draw()
  self:drawBorders()
end

return LevelUpPanel