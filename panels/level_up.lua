local Panel = require "panel"
local Colors = require "colors"
local FeatsPanel = require "panels.feats"

local LevelUpPanel = Panel:extend()
LevelUpPanel.options = {
  ["1"] = "STR",
  ["2"] = "DEX",
  ["3"] = "CON",
  ["4"] = "INT"
}

LevelUpPanel.feats = {
  ["STR"] = {
  },

  ["DEX"] = {
    {conditions.Rapidfire}
  },

  ["CON"] = {
  },

  ["INT"] = {
  },

  ["WIS"] = {
  }
}

function LevelUpPanel:__new(display, parent)
  Panel.__new(self, display, parent, 23, 15, 27, 17)
end

function LevelUpPanel:draw()
  self:clear()
  self:drawBorders()
  self:writeFormatted({"1) ", Colors.RED, "STR"}, 2, 3)
  self:write("    \16Hit things harder.", 2, 4)
  self:writeFormatted({"2) ", Colors.GREEN, "DEX"}, 2, 6)
  self:writeFormatted({"3) ", Colors.YELLOW, "CON"}, 2, 8)
  self:writeFormatted({"4) ", Colors.BLUE, "INT"}, 2, 10)
  self:writeFormatted({"5) ", Colors.PURPLE, "WIS"}, 2, 12)
end

function LevelUpPanel:handleKeyPress(keypress)
  local stat = self.options[keypress]
  if stat then
    local statLevel = game.curActor.levels[stat] + 1
    local feats = self.feats[stat][statLevel]

    game.interface:pop()

    if feats then
      game.interface:push(FeatsPanel(self.display, self.parent, stat, feats))
    else
      game.interface:setAction(actions.Level(game.curActor, stat))
    end
  end
end

return LevelUpPanel