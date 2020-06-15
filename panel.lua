local Object = require "object"
local Tiles = require "tiles"

local Panel = Object:extend()
Panel.borderColor = {.5, .5, .6, 1}

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

function Panel:drawBorders(width, height)
  local w = width or self.w
  local h = height or self.h
  local half_width = (w - 3) / 2
  local half_height = (h - 3) / 2

  -- Top border
  self:write(Tiles["b_top_left_corner"], 1, 1, Panel.borderColor)
  self:drawHorizontal(Tiles["b_top_left"], 1, half_width, 1)
  self:write(Tiles["b_top_middle"], half_width + 2, 1, Panel.borderColor)
  self:drawHorizontal(Tiles["b_top_right"], half_width + 2, half_width * 2 + 1, 1)
  self:write(Tiles["b_top_right_corner"], w, 1, Panel.borderColor)

  -- Bottom border
  self:write(Tiles["b_left_bottom_corner"], 1, h, Panel.borderColor)
  self:drawHorizontal(Tiles["b_bottom_left"], 1, half_width, h)
  self:write(Tiles["b_bottom_middle"], half_width + 2, h, Panel.borderColor)
  self:drawHorizontal(Tiles["b_bottom_right"], half_width + 2, half_width * 2 + 1, h)
  self:write(Tiles["b_bottom_right_corner"], w, h, Panel.borderColor)

  -- Left border
  self:drawVertical(Tiles["b_left_top"], 1, half_height, 1)
  self:write(Tiles["b_left_middle"], 1, half_height + 2, Panel.borderColor)
  self:drawVertical(Tiles["b_left_bottom"], half_height + 2, half_height * 2 + 1, 1)

  -- Right border
  self:drawVertical(Tiles["b_right_top"], 1, half_height, w)
  self:write(Tiles["b_right_middle"], w, half_height + 2, Panel.borderColor)
  self:drawVertical(Tiles["b_right_bottom"], half_height + 2, half_height * 2 + 1, w)
end

function Panel:drawHorizontal(c, first, last, y) 
  for i = first, last do 
    self:write(c, 1 + i, y, Panel.borderColor)
  end
end

function Panel:drawVertical(c, first, last, x)
  for i = first, last do 
    self:write(c, x, 1 + i, Panel.borderColor)
  end
end

function Panel:update(dt)
end

function Panel:write(c, x, y, fg, bg)
  local w = type(c) == "string" and x + string.len(c) - 1 or 1
  if x < 1 or w > self.w or y < 1 or y > self.h then
    error("Tried to write out of bounds to a panel!")
  end

  self.display:write(c, self.x + x - 1, self.y + y - 1, fg, bg)
end

function Panel:handleKeyPress(keypress)
  if keypress == "backspace" then
    game.interface:pop()
  end
end

return Panel
