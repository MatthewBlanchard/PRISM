local Panel = require "panel"

local LevelUpPanel = Panel:extend()
LevelUpPanel.options = {
  ["1"] = "STR",
  ["2"] = "DEX",
  ["3"] = "CON",
  ["4"] = "INT"
}

function LevelUpPanel:__new(display, parent)
  Panel.__new(self, display, parent, 23, 15, 27, 15)
end

function LevelUpPanel:draw()
  self:clear()
  self:drawBorders()
  self:writeFormatted({"1) ", {1, 0, 0, 1}, "STR"}, 2, 3)
  self:write("    \16Hit things harder.", 2, 4)
  self:writeFormatted({"2) ", {0, 1, 0, 1}, "DEX"}, 2, 6)
  self:writeFormatted({"3) ", {1, 1, 0, 1}, "CON"}, 2, 8)
  self:writeFormatted({"4) ", {0, 0, 1, 1}, "STR"}, 2, 10)
end

function LevelUpPanel:handleKeyPress(keypress)
  local stat = self.options[keypress]
  if stat then
    game.interface:setAction(actions.Level(game.curActor, stat))
    game.interface:pop()
  end
end

return LevelUpPanel