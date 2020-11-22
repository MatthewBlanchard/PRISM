local Object = require "object"
local Tiles = require "tiles"

local Panel = Object:extend()
Panel.borderColor = {.5, .5, .6, 1}
Panel.defaultForegroundColor = {1, 1, 1}
Panel.backgroundColor = {.09, .09, .09}

function Panel:__new(display, parent, x, y, w, h)
  self.display = display
  self.parent = parent
  self.x = x or 1
  self.y = y or 1
  self.w = w or display and display:getWidth() or 1
  self.h = h or display and display:getHeight() or 1
  self.defaultBackgroundColor = Panel.backgroundColor

  self.panels = {}
end

function Panel:getRoot()
  local parent = self.parent
  local prev = self
  while parent do
    prev = parent
    parent = parent.parent
  end
  return prev
end

function Panel:draw(x, y)
end

function Panel:clear(c, fg, bg)
  self.display:clear(c or ' ', self.x, self.y, self.w, self.h, fg, bg or self.defaultBackgroundColor)
end

function Panel:darken(c, fg, bg)
  for x = self.x, self.x + self.w - 1 do
    for y = self.y, self.y + self.h - 1 do
      local bg = self.display:getBackgroundColor(x, y)
      bg = ROT.Color.multiplyScalar(bg, 0.15)
      self.display:write(' ', x, y, {1, 1, 1}, bg)
    end
  end
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

function Panel:writeOffset(toWrite, x, y, fg, bg)
  local viewX, viewY = game.viewDisplay.widthInChars, game.viewDisplay.heightInChars
  local mx = (x - (game.curActor.position.x - math.floor(viewX/2)))
  local my = (y - (game.curActor.position.y - math.floor(viewY/2)))

  if mx < 1 or mx > game.viewDisplay.widthInChars or my < 1 or my > game.viewDisplay.heightInChars then
    return
  end

  game.viewDisplay:write(toWrite, mx, my, fg, bg)
end

function Panel:effectWriteOffset(toWrite, x, y, fg, bg)
  local viewX, viewY = game.viewDisplay.widthInChars, game.viewDisplay.heightInChars
  local mx = (x - (game.curActor.position.x - math.floor(viewX/2)))
  local my = (y - (game.curActor.position.y - math.floor(viewY/2)))

  if mx < 1 or mx > game.viewDisplay.widthInChars or my < 1 or my > game.viewDisplay.heightInChars then
    return
  end

  if not game.curActor.fov[x] or not game.curActor.fov[x][y] then
    return
  end

  self._curEffectDone = false
  game.viewDisplay:write(toWrite, mx, my, fg, bg)
end

function Panel:effectWriteOffsetUI(toWrite, x, y, ofx, ofy, fg, bg)
  local viewX, viewY = game.viewDisplay.widthInChars, game.viewDisplay.heightInChars
  local mx = (x - (game.curActor.position.x - math.floor(viewX/2)))
  local my = (y - (game.curActor.position.y - math.floor(viewY/2)))

  if mx < 1 or mx > game.viewDisplay.widthInChars or my < 1 or my > game.viewDisplay.heightInChars then
    return
  end

  if not game.curActor.fov[x] or not game.curActor.fov[x][y] then
    return
  end

  local scale = game.viewDisplay.scale
  self._curEffectDone = false
  self:write(toWrite, mx * scale + ofx, my * scale + ofy, fg, bg)
end

function Panel:writeOffsetBG(x, y, bg)
  local interface = game.interface
  local mx = (x - (game.curActor.position.x - interface.viewX)) + 1
  local my = (y - (game.curActor.position.y - interface.viewY)) + 1

  self:writeBG(mx, my, bg)
end

function Panel:drawHorizontal(c, first, last, y)
  for i = first, last do
    self:write(c, 1 + i, y, Panel.borderColor, Panel.backgroundColor)
  end
end

function Panel:drawVertical(c, first, last, x)
  for i = first, last do
    self:write(c, x, 1 + i, Panel.borderColor, Panel.backgroundColor)
  end
end

function Panel:update(dt)
end

function Panel:write(c, x, y, fg, bg)
  local w = type(c) == "string" and x + string.len(c) - 1 or 1
  if x < 1 or w > self.w or y < 1 or y > self.h then
    error("Tried to write out of bounds to a panel!")
  end

  self.display:write(c, self.x + x - 1, self.y + y - 1, fg or self.defaultForegroundColor, bg or self.defaultBackgroundColor)
end

function Panel:writeBG(x, y, bg)
  if x < 1 or x > self.w or y < 1 or y > self.h then
    error("Tried to write out of bounds to a panel!")
  end

  self.display:writeBG(self.x + x - 1, self.y + y - 1, bg)
end
function Panel:writeFormatted(s, x, y, bg)
  if x < 1 or y < 1 or y > self.h then
    error("Tried to write out of bounds to a panel!")
  end

  self.display:writeFormatted(s, self.x + x - 1, self.y + y - 1, bg or self.defaultBackgroundColor)
end

function Panel:writeText(s, x, y, maxWidth)
  if x < 1 or y < 1 or y > self.h then
    error("Tried to write out of bounds to a panel!")
  end

  self.display:drawText(self.x + x - 1, self.y + y - 1, s, maxWidth)
end

function Panel:correctWidth(s, w)
  if string.len(s) < w then
    return s .. string.rep(" ", w - string.len(s))
  elseif string.len(s) > w then
    return string.sub(s, 1, w)
  else
    return s
  end
end

function Panel:correctHeight(h)
  if h % 2 == 0 then
    return h + 1
  else
    return h
  end
end

function Panel:handleKeyPress(keypress)
  if keypress == "backspace" then
    game.interface:pop()
  end
end

return Panel
