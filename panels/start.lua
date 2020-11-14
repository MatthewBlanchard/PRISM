local Panel = require "panel"

local Start = Panel:extend()

function Start:__new(display)
  Panel.__new(self, display, parent)
end

function Start:draw()
  self.display:writeCenter("Below the Garden", math.floor(self.h / 2))
end

return Start
