local Panel = require "panel"
local Colors = require "colors"
local FeatsPanel = require "panels.feats"

local LevelUpPanel = Panel:extend()

function LevelUpPanel:__new(display, parent)
  Panel.__new(self, display, parent, 23, 15, 27, 17)
end

function LevelUpPanel:draw()
  self:clear()
  self:drawBorders()
end

function LevelUpPanel:handleKeyPress(keypress)
  local feat = self.options[keypress]
  if stat then
    local statLevel = game.curActor.levels[stat] + 1
    local feats = self.feats[stat][statLevel]

    game.interface:pop()

    if feats then
      game.interface:push(FeatsPanel(self.display, self.parent, stat, feats))
    else
      game.level:performAction(actions.Level(game.curActor, stat))
    end
  end
end

return LevelUpPanel
