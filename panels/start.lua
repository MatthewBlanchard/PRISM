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
  local a = 1
  local t = math.min(1, self.time / 4)

  if self.fadeTime then
    local timeSinceFade = self.time - self.fadeTime
    a = math.abs((timeSinceFade / 2) - 1)
    if timeSinceFade > 2 then
      game.interface:pop()
    end

    t = 1
  end

  local tC = math.max(0.09, 0.9 * t)
  self.display:clear(nil, nil, nil, nil, nil, nil, { .09, .09, .09, a })
  self.display:writeCenter("The Garden", math.floor(self.h / 2) - 10, { tC, tC, tC, a }, { .09, .09, .09, a })
  self.display:writeCenter("Press any key to begin.", math.floor(self.h / 2), { tC, tC, tC, a }, { .09, .09, .09, a })
end

function Start:handleKeyPress(keypress)
  if self.fadeTime then
    game.interface:pop()
  end
  self.fadeTime = self.time
  game.music:changeSong(game.music.mainmusic)
end

return Start
