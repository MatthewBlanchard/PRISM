local Panel = require "panel"

local Start = Panel:extend()

function Start:__new(display)
  Panel.__new(self, display, parent)
end

function Start:draw()
  self.display:clear(nil, nil, nil, nil, nil, nil, {0, 0, 0})
  self.display:writeCenter("Below the Garden", math.floor(self.h / 2), {0.5, 0.5, 0.7}, {0, 0, 0})
end

function Start:handleKeyPress(keypress)
  game.interface:pop()
end

return Start
