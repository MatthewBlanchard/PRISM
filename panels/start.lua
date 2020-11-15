local Panel = require "panel"

local Start = Panel:extend()

function Start:__new(display)
  Panel.__new(self, display, parent)
end

function Start:update(dt)
  self.time = self.time or 0
  self.time = self.time + dt
end
function Start:draw()
  local t = math.min(1, self.time / 4)
  local tC = 0.9 * t
  self.display:clear(nil, nil, nil, nil, nil, nil, {.09, .09, .09})
  self.display:writeCenter("Below the Garden", math.floor(self.h / 2)-10, {tC, tC, tC}, {.09, .09, .09})
  self.display:writeCenter("Press any key to begin.", math.floor(self.h / 2), {tC, tC, tC}, {.09, .09, .09})
end

function Start:handleKeyPress(keypress)
  game.interface:pop()
end

return Start
