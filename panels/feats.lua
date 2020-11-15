local Panel = require "panel"
local Colors = require "colors"

local FeatsPanel = Panel:extend()

function FeatsPanel:__new(display, parent, feats)
  Panel.__new(self, display, parent, 23, 15, 27, 17)
  self.feats = feats
  self.stat = stat
end

function FeatsPanel:draw()
  self:clear()
  self:drawBorders() 

  if #self.feats == 1 then 
    self:write("Gained a Feat!", 8, 2)
    local feat = self.feats[1]
    self:writeText(feat.name, 3, 4)
    self:writeText(feat.description, 3, 5, self.w - 3)
  else
    self:write("Pick a Feat!", 9, 2)
    local descHeight = 0
    local extra = 0
    for i, feat in ipairs(self.feats) do 
      self:writeFormatted({Colors.YELLOW, i .. ") " .. feat.name}, 2, i * 2 + 2 + extra + descHeight)
      self:writeText("%b{black}" .. feat.description, 5, i * 2 + 3 + extra + descHeight, self.w - 5)
      descHeight = math.ceil(#feat.description / (self.w - 3))
      extra = 1
    end
  end
end

function FeatsPanel:handleKeyPress(keypress)
  if #self.feats == 1 then
    if keypress == "return" then 
      game.interface:setAction(actions.Level(game.curActor, self.stat, self.feats[1]))
      game.interface:reset()
    end
  else
    local feat = self.feats[tonumber(keypress)]
    if feat then 
      game.interface:setAction(actions.Level(game.curActor, self.stat, feat))
      game.interface:reset()
    end
  end
end

return FeatsPanel