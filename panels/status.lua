local Panel = require "panel"

local StatusPanel = Panel:extend()

function StatusPanel:__new(display, parent)
  local x, y = game.display:getWidth() - 17, game.display:getHeight()
  Panel.__new(self, display, parent, x, 1, 17, 11)
end

function StatusPanel:draw()
  self:drawBorders()
  local hpPercentage = game.curActor.HP / game.curActor.maxHP
  local barLength = math.floor(15 * hpPercentage)
  local hpString = tostring(game.curActor.HP) .. "/" .. tostring(game.curActor.maxHP) .. " HP"

  for i = 1, 15 do
    local c = string.sub(hpString, i, i)
    c = c == "" and " " or c

    local bg = barLength >= i and {.3, .3, .3, 1} or {.2, .1, .1, 1}
    self:write(c, i + 1, 5, {.75, .75, .75, 1}, bg)
  end

  self:write("STR DEX CON INT", 2, 2)
  local stats = self:statToString(game.curActor.STR) 
  self:write(self:statsToString(game.curActor), 2, 3)
  local statbonus = game.curActor:getStatBonus(game.curActor.wielded.stat)
  self:write(game.curActor.wielded.name, 2, 6, {.75, .75, .75, 1})
  self:write("AC: " .. game.curActor:getAC(), 2, 7, {.75, .75, .75, 1})
end

function StatusPanel:statsToString(actor)
  local STR = actor:getStat("STR")
  local DEX = actor:getStat("DEX")
  local CON = actor:getStat("CON")
  local INT = actor:getStat("INT")

  return self:statToString(STR) .. " " .. self:statToString(DEX) .. " " ..
         self:statToString(CON) .. " " .. self:statToString(INT)
end

function StatusPanel:statToString(stat)
  local s = tostring(stat)

  if #s == 1 then return "  " .. s end
  if #s == 2 then return " " .. s end
  return s
end

return StatusPanel
