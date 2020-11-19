local Panel = require "panel"
local SwirlPanel = require "panels.swirl"
local Colors = require "colors"

local messages = {
  "Gaze upon uncomfortable truths!",
  "Comtemplate the unknowable!",
  "Ponder your own mortality",
  
}
local FeatsPanel = Panel:extend()

function FeatsPanel:__new(display, parent, feats)
  local halfx = display:getWidth()/2 - 33/2
  local halfy = display:getHeight()/2 - 27/2
  Panel.__new(self, display, parent, math.floor(halfx), math.floor(halfy), 33, 27)

  self.SwirlPanel = SwirlPanel(display, parent)
  self.feats = feats
  self.stat = stat
end

function FeatsPanel:update(dt)
  self.SwirlPanel:update(dt)
end

function FeatsPanel:draw()
  self.SwirlPanel:draw(dt)

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
    for k, feat in pairs(self.feats) do
      self:writeFormatted({Colors.YELLOW, k .. ") " .. feat.name}, 2, k * 2 + 2 + extra + descHeight)
      self:writeText("%b{black}" .. feat.description, 5, k * 2 + 3 + extra + descHeight, self.w - 5)
      descHeight = descHeight + math.ceil(#feat.description / (self.w - 5))
      extra = extra + 1
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
      game.music:changeSong(game.music.mainmusic)
      game.interface:setAction(actions.Level(game.curActor, feat))
      game.interface:reset()
    end
  end
end

return FeatsPanel
