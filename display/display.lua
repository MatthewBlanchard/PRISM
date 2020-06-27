--- Visual Display.
-- A Code Page 437 terminal emulator based on AsciiPanel.
local Display = {}
local util = require 'display.util'
Display.defaultTileset = {
   path = 'display/cp437_15x15.png',
   perRow = 16,
   perColumn = 24,
   charWidth = 15,
   charHeight = 15,
}

--- Constructor.
-- The display constructor. 
-- @tparam[opt=80] int w Width of display in number of characters
-- @tparam[opt=24] int h Height of display in number of characters
-- @tparam[opt=1] float scale Window scale modifier applied to glyph dimensions
-- @tparam[opt] table dfg Default foreground color as a table defined as {r,g,b,a}
-- @tparam[opt] table dbg Default background color
-- @tparam[opt=false] boolean fullOrFlags In Love 0.8.0: Use fullscreen In Love 0.9.0: a table defined for love.graphics.setMode
-- @tparam[opt={path = 'cp437_12x12.png', perRow = 16, perColumn = 16, charHeight = 12, charWidth = 12}] table Information for custom tilesets
-- @tparam[opt=false] boolean noWindow Whether to setMode or not
-- @return nil
function Display:new(w, h, scale, dfg, dbg, fullOrFlags, tilesetInfo, window)
   local t = {}
   setmetatable(t, self)
   self.__index = self
   local tilesetInfo = tilesetInfo or Display.defaultTileset
   t.tilesetChanged = false
   t.__name = 'Display'
   t.widthInChars = w and w or 80
   t.heightInChars = h and h or 24
   t.scale = scale or 1
   t.glyphs = {}
   t.chars = {{}}
   t.backgroundColors = {{}}
   t.foregroundColors = {{}}
   t.oldChars = {{}}
   t.oldBackgroundColors = {{}}
   t.oldForegroundColors = {{}}
   t.graphics = love.graphics

   t:setTileset(tilesetInfo)

   if window then
      love.window.setMode(t.charWidth*t.widthInChars, t.charHeight*t.heightInChars, {vsync=false})
   end

   t.drawQ = t.graphics.draw

   t.defaultForegroundColor = dfg or { 0.9215686274509803, 0.9215686274509803, 0.9215686274509803 }

   t.defaultBackgroundColor = dbg or { 0.058823529411764705, 0.058823529411764705, 0.058823529411764705 }

   t.graphics.setBackgroundColor(t.defaultBackgroundColor)

   t.canvas = t.graphics.newCanvas(t.charWidth*t.widthInChars, t.charHeight*t.heightInChars)

   for i = 1, t.widthInChars do
      t.chars[i]               = {}
      t.backgroundColors[i]    = {}
      t.foregroundColors[i]    = {}
      t.oldChars[i]            = {}
      t.oldBackgroundColors[i] = {}
      t.oldForegroundColors[i] = {}
      for j = 1,t.heightInChars do
         t.chars[i][j]               = 32
         t.backgroundColors[i][j]    = t.defaultBackgroundColor
         t.foregroundColors[i][j]    = t.defaultForegroundColor
         t.oldChars[i][j]            = nil
         t.oldBackgroundColors[i][j] = nil
         t.oldForegroundColors[i][j] = nil
      end
   end

   return t
end

--- Draw.
-- The main draw function. This should be called from love.draw() to display any written characters to screen
function Display:draw(noDraw)
	local startX = 1
	local endX = self.widthInChars
	local startY = 1
	local endY = self.heightInChars

   self.graphics.setCanvas(self.canvas)
   for x = startX, endX do
      for y = startY, endY do
         local c = self.chars[x][y]
         local bg = self.backgroundColors[x][y]
         local fg = self.foregroundColors[x][y]
         local px = (x-1)*self.charWidth
         local py = (y-1)*self.charHeight
         if self.oldChars[x][y]            ~= c  or
            self.oldBackgroundColors[x][y] ~= bg or
            self.oldForegroundColors[x][y] ~= fg or 
			self.tilesetChanged                  then

            self:_setColor(bg)
            self.graphics.rectangle('fill', px, py, self.charWidth, self.charHeight)
            if c ~= 32 and c ~= 255 then
               local qd = self.glyphs[c]
               self:_setColor(fg)
               self.drawQ(self.glyphSprite, qd, px, py, nil, self.scale)
            end

            self.oldChars[x][y]            = c
            self.oldBackgroundColors[x][y] = bg
            self.oldForegroundColors[x][y] = fg
         end
      end
   end
   self.tilesetChanged = false
   self.graphics.setCanvas()
   self.graphics.setColor(1, 1, 1, 1)
   if noDraw then return end
   self.graphics.draw(self.canvas)
end

--- Change the tileset.
-- Accepts the same table format as the one passed to the constructor.
function Display:setTileset(tilesetInfo)
   self.imageCharWidth = tilesetInfo.charWidth
   self.imageCharHeight = tilesetInfo.charHeight
   self.charWidth = self.imageCharWidth * self.scale
   self.charHeight = self.imageCharHeight * self.scale
   self.glyphSprite = self.graphics.newImage(tilesetInfo.path)

   local i = 0
   for y = 0, tilesetInfo.perColumn - 1 do
      local sy = y * self.imageCharHeight
      for x = 0, tilesetInfo.perRow - 1 do
         local sx = x * self.imageCharWidth
         self.glyphs[i] = self.graphics.newQuad(sx, sy, self.imageCharWidth, self.imageCharHeight, self.glyphSprite:getWidth(), self.glyphSprite:getHeight())
         i = i + 1
      end
   end

   self.tilesetChanged = true
end

--- Contains point.
-- Returns true if point x,y can be drawn to display.
function Display:contains(x, y)
   return x > 0 and x <= self:getWidth() and y > 0 and y <= self:getHeight()
end

function Display:getCharHeight() return self.charHeight end
function Display:getCharWidth() return self.charWidth end
function Display:getWidth() return self:getWidthInChars() end
function Display:getHeight() return self:getHeightInChars() end
function Display:getHeightInChars() return self.heightInChars end
function Display:getWidthInChars() return self.widthInChars end
function Display:getDefaultBackgroundColor() return self.defaultBackgroundColor end
function Display:getDefaultForegroundColor() return self.defaultForegroundColor end

--- Get a character.
-- returns the character being displayed at position x, y
-- @tparam int x The x-position of the character
-- @tparam int y The y-position of the character
-- @treturn string The character
function Display:getCharacter(x, y)
   local c = self.chars[x][y]
   return c and string.char(c) or nil
end

--- Get a background color.
-- returns the current background color of the character written to position x, y
-- @tparam int x The x-position of the character
-- @tparam int y The y-position of the character
-- @treturn table The background color as a table defined as {r,g,b,a}
function Display:getBackgroundColor(x, y) return self.backgroundColors[x][y] end

--- Get a foreground color.
-- returns the current foreground color of the character written to position x, y
-- @tparam int x The x-position of the character
-- @tparam int y The y-position of the character
-- @treturn table The foreground color as a table defined as {r,g,b,a}
function Display:getForegroundColor(x, y) return self.foregroundColors[x][y] end

--- Set Default Background Color.
-- Sets the background color to be used when it is not provided
-- @tparam table c The background color as a table defined as {r,g,b,a}
function Display:setDefaultBackgroundColor(c)
   self.defaultBackgroundColor=c and c or self.defaultBackgroundColor
end

--- Set Defaul Foreground Color.
-- Sets the foreground color to be used when it is not provided
-- @tparam table c The foreground color as a table defined as {r,g,b,a}
function Display:setDefaultForegroundColor(c)
   self.defaultForegroundColor=c and c or self.defaultForegroundColor
end

--- Clear the screen.
-- By default wipes the screen to the default background color.
-- You can provide a character, x-position, y-position, width, height, fore-color and back-color
-- and write the same character to a portion of the screen
-- @tparam[opt=' '] string c A character to write to the screen - may fail for strings with a length > 1
-- @tparam[opt=1] int x The x-position from which to begin the wipe
-- @tparam[opt=1] int y The y-position from which to begin the wipe
-- @tparam[opt] int w The number of chars to wipe in the x direction
-- @tparam[opt] int h Then number of chars to wipe in the y direction
-- @tparam[opt] table fg The color used to write the provided character
-- @tparam[opt] table bg the color used to fill in the background of the cleared space
function Display:clear(c, x, y, w, h, fg, bg)
   c = c or ' '
   w = w or self.widthInChars
   local s = c:rep(w)
   x = self:_validateX(x, s)
   y = self:_validateY(y)
   h = self:_validateHeight(y, h)
   fg = self:_validateForegroundColor(fg)
   bg = self:_validateBackgroundColor(bg)
   for i = 0, h-1 do
      self:_writeValidatedString(s, x, y+i, fg, bg)
   end
end

--- Write.
-- Writes a string to the screen
-- @tparam string s The string to be written
-- @tparam[opt=1] int x The x-position where the string will be written
-- @tparam[opt=1] int y The y-position where the string will be written
-- @tparam[opt] table fg The color used to write the provided string
-- @tparam[opt] table bg the color used to fill in the string's background
function Display:write(s, x, y, fg, bg)
   if type(s) == "number" then
      self:writeChar(s, x, y, fg, bg)
      return nil
   end

   util.assert(s, "Display:write() must have string as param")
   x = self:_validateX(x, s)
   y = self:_validateY(y, s)
   fg = self:_validateForegroundColor(fg)
   bg = self:_validateBackgroundColor(bg)

   self:_writeValidatedString(s, x, y, fg, bg)
end

function Display:writeFormatted(s, x, y, bg)
   if type(s) ~= "table" then
      util.assert(s, "Display:writeFormatted() must have table as param")
      return
   end

   local currentX = x
   local currentFg = nil
   for i = 1, #s do 
      if type(s[i]) == "string" then 
         self:write(s[i], currentX, y, currentFg, bg)
         currentX = currentX + #s[i]
      elseif type(s[i]) == "table" then
         currentFg = s[i]
      end
   end
end

--- Write.
-- Writes a char (index) to the screen
-- @tparam number index The char to be written
-- @tparam[opt=1] int x The x-position where the char will be written
-- @tparam[opt=1] int y The y-position where the char will be written
-- @tparam[opt] table fg The color used to write the provided char 
-- @tparam[opt] table bg the color used to fill in the char's background
function Display:writeChar(index, x, y, fg, bg)
   x = self:_validateX(x)
   y = self:_validateY(y)
   fg = self:_validateForegroundColor(fg)
   bg = self:_validateBackgroundColor(bg)

   self.backgroundColors[x][y] = bg
   self.foregroundColors[x][y] = fg
   self.chars[x][y] = index
end

function Display:writeBG(x, y, bg)
   x = self:_validateX(x)
   y = self:_validateY(y)
   bg = self:_validateBackgroundColor(bg)

   self.backgroundColors[x][y] = bg
end

function Display:writeCharCentre(index, y, fg, bg)
   self:writeChar(index, self.widthInChars / 2, fg, bg)
end

--- Write Center.
-- write a string centered on the middle of the screen
-- @tparam string s The string to be written
-- @tparam[opt=1] int y The y-position where the string will be written
-- @tparam[opt] table fg The color used to write the provided string
-- @tparam[opt] table bg the color used to fill in the string's background
function Display:writeCenter(s, y, fg, bg)
   if type(s) == "number" then
      self:writeCharCentre(s, y, fg, bg)
   end
   util.assert(s, "Display:writeCenter() must have string as param")
   util.assert(#s < self.widthInChars, "Length of ", s, " is greater than screen width")

   y = y and y or math.floor((self:getHeightInChars() - 1) / 2)
   y = self:_validateY(y)
   fg = self:_validateForegroundColor(fg)
   bg = self:_validateBackgroundColor(bg)

   local x = math.floor((self.widthInChars - #s) / 2)
   self:_writeValidatedString(s, x, y, fg, bg)
end

function Display:_writeValidatedString(s, x, y, fg, bg)
   for i = 1,#s do
      self.backgroundColors[x+i-1][y] = bg
      self.foregroundColors[x+i-1][y] = fg
      self.chars[x+i-1][y]            = s:byte(i)
   end
end

function Display:_validateX(x, s)
   x = x and x or 1
   util.assert(x > 0 and x <= self.widthInChars, "X value must be between 0 and ",self.widthInChars)
   util.assert((x + #s) - 1 <= self.widthInChars, "X value plus length of String must be between 0 and ", self.widthInChars)
   return x
end

function Display:_validateX(x)
   x = x and x or 1
   util.assert(x > 0 and x <= self.widthInChars, "X value must be between 0 and ",self.widthInChars)
   util.assert(x - 1 <= self.widthInChars, "X value plus length of String must be between 0 and ", self.widthInChars)
   return x
end

function Display:_validateY(y)
   y = y and y or 1
   util.assert(y > 0 and y <= self.heightInChars, "Y value must be between 0 and ", self.heightInChars)
   return y
end

function Display:_validateForegroundColor(c)
   c = c or self.defaultForegroundColor
   util.assert(#c > 2, 'Foreground Color must have at least 3 components')
   for i = 1, #c do c[i]=self:_clamp(c[i]) end
   return c
end

function Display:_validateBackgroundColor(c)
   c = c or self.defaultBackgroundColor
   util.assert(#c > 2, 'Background Color must have at least 3 components')
   for i = 1, #c do c[i]=self:_clamp(c[i]) end
   return c
end

function Display:_validateHeight(y, h)
   h=h and h or self.heightInChars-y+1
   util.assert(h>0, "Height must be greater than 0. Height provided: ",h)
   util.assert(y+h-1<=self.heightInChars, "Height + y value must be less than screen height. y, height: ",y,', ',h)
   return h
end

function Display:_setColor(c)
   love.graphics.setColor(c or self.defaultForegroundColor)
end

function Display:_clamp(n)
   return n<0 and 0 or n>255 and 255 or n
end

--- Draw text.
-- Draws a text at given position. Optionally wraps at a maximum length.
-- @tparam number x
-- @tparam number y
-- @tparam string text May contain color/background format specifiers, %c{name}/%b{name}, both optional. %c{}/%b{} resets to default.
-- @tparam number maxWidth wrap at what width (optional)?
-- @treturn number lines drawn
function Display:drawText(x, y, text, maxWidth)
   local fg
   local bg
   local cx = x
   local cy = y
   local lines = 1
   if not maxWidth then maxWidth = self.widthInChars-x end

   local tokens = util.tokenize(text, maxWidth)

   while #tokens > 0 do -- interpret tokenized opcode stream
      local token = table.remove(tokens, 1)
      if token.type == util.TYPE_TEXT then
         local isSpace, isPrevSpace, isFullWidth, isPrevFullWidth
         for i = 1, #token.value do
               local cc = token.value:byte(i)
               local c = token.value:sub(i, i)
               -- TODO: chars will never be full-width without special handling
               -- TODO: ... so the next 15 lines or so do some pointless stuff
               -- Assign to `true` when the current char is full-width.
               isFullWidth = (cc > 0xff00 and cc < 0xff61)
                  or (cc > 0xffdc and cc < 0xffe8)
                  or cc > 0xffee
               -- Current char is space, whatever full-width or half-width both are OK.
               isSpace = c:byte() == 0x20 or c:byte() == 0x3000
               -- The previous char is full-width and
               -- current char is nether half-width nor a space.
               if isPrevFullWidth and not isFullWidth and not isSpace then
                  cx = cx + 1 -- add an extra position
               end
               -- The current char is full-width and
               -- the previous char is not a space.
               if isFullWidth and not isPrevSpace then
                  cx = cx + 1 -- add an extra position
               end
               fg = (fg == '' or not fg) and self.defaultForegroundColor
                  or type(fg) == 'string' and util.Color.fromString(fg) or fg
               bg = (bg == '' or not bg) and self.defaultBackgroundColor
                  or type(bg) == 'string' and util.Color.fromString(bg) or bg
               self:_writeValidatedString(c, cx, cy, fg, bg)
               cx = cx + 1
               isPrevSpace = isSpace
               isPrevFullWidth = isFullWidth
         end
      elseif token.type == util.TYPE_FG then
         fg = token.value or nil
      elseif token.type == util.TYPE_BG then
         bg = token.value or nil
      elseif token.type == util.TYPE_NEWLINE then
         cx = x
         cy = cy + 1
         lines = lines + 1
      end
   end

   return lines
end

return Display
