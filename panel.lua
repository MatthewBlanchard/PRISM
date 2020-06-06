local Object = require "object"

local Panel = Object:extend()

function Panel:__new(display, parent, x, y, w, h)
  self.display = display
  self.parent = parent
  self.x = x or 1
  self.y = y or 1
  self.w = w or display and display:getWidth() or 1
  self.h = h or display and display:getHeight() or 1

  self.panels = {}
end

function Panel:draw(x, y)
end

function Panel:update(dt)
end

function Panel:write(c, x, y, fg, bg)
  local w, h = x + string.len(c) - 1
  if x < 1 or w > self.w or y < 1 or y > self.h then
    error("Tried to write out of bounds to a panel!")
  end

  display:write(c, self.x + x - 1, self.y + y - 1, fg, bg)
end

function Panel:writeChar(c, x, y, fg, bg)
  if x < 1 or x > self.w or y < 1 or y > self.h then
    error("Tried to write out of bounds to a panel!")
  end

  display:writeChar(c, self.x + x - 1, self.y + y - 1, fg, bg)
end

function Panel:handleKeyPress(keypress)
  if keypress == "backspace" then
    game.interface:pop()
  end
end

return Panel
