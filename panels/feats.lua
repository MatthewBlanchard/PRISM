local Panel = require "panel"
local SwirlPanel = require "panels.swirl"
local Colors = require "colors"

local messages = {
  "Gaze upon terrible truths!",
  "Comtemplate the unknowable!",
  "Ponder the possibilities!",
}

local FeatsPanel = Panel:extend()

function FeatsPanel:__new(display, parent, feats)
  local halfx = display:getWidth()/2 - 33/2
  local halfy = display:getHeight()/2 - 27/2
  Panel.__new(self, display, parent, math.floor(halfx) + 1, math.floor(halfy), 33, 27)

  self.SwirlPanel = SwirlPanel(display, parent)
  self.feats = feats
  self.stat = stat
end

function FeatsPanel:update(dt)
  self.SwirlPanel:update(dt)
end

function FeatsPanel:draw()
  self.SwirlPanel:draw(dt)

  self:darken(' ', nil, {0.2, 0.2, 0.2, 0.7})
  self:drawBorders()

  if #self.feats == 1 then
    local msgLen = string.len("Gaze upon terrible truths!")
    self:write("Gaze upon terrible truths!", 8, 2)
    local feat = self.feats[1]
    self:writeText(feat.name, 3, 4)
    self:writeText(feat.description, 3, 5, self.w - 3)
  else
    local msgLen = math.floor(string.len("Gaze upon uncomfortable truths!")/2)
    self:write("Gaze upon terrible truths!", math.floor(self.w/2)-msgLen+1, 2)

    local descHeight = 0
    local extra = 0
    for k, feat in pairs(self.feats) do
      self:writeFormatted({Colors.YELLOW, k .. ") " .. feat.name}, 2, k * 2 + 3 + extra + descHeight)
      self:writeText("%b{black}" .. feat.description, 5, k * 2 + 4 + extra + descHeight, self.w - 5)
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
