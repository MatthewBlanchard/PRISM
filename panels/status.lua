local Panel = require "panel"
local Colors = require "colors"

local formatted = {Colors.RED, "STR ", Colors.GREEN, "DEX ", Colors.YELLOW, "CON ", Colors.BLUE, "INT ", Colors.PURPLE, "WIS"}

local StatusPanel = Panel:extend()

function StatusPanel:__new(display, parent)
  local x, y = game.display:getWidth() - 20, game.display:getHeight()
  Panel.__new(self, display, parent, x, 1, 21, 11)
end

function StatusPanel:draw()
  self:drawBorders()
  local hpPercentage = game.curActor.HP / game.curActor.maxHP
  local barLength = math.floor(19 * hpPercentage)
  local hpString = tostring(game.curActor.HP) .. "/" .. tostring(game.curActor.maxHP) .. " HP"

  for i = 1, 19 do
    local c = string.sub(hpString, i, i)
    c = c == "" and " " or c

    local bg = barLength >= i and {.3, .3, .3, 1} or {.2, .1, .1, 1}
    self:write(c, i + 1, 5, {.75, .75, .75, 1}, bg)
  end

  self:writeFormatted(formatted, 2, 2)
  local stats = self:statToString(game.curActor.STR) 
  self:write(self:statsToString(game.curActor), 2, 3)
  local statbonus = game.curActor:getStatBonus(game.curActor.wielded.stat)
  self:write(game.curActor.wielded.name, 2, 6, {.75, .75, .75, 1})
  self:write("AC: " .. game.curActor:getAC(), 2, 7, {.75, .75, .75, 1})

  local i = 9
  for k, v in pairs(game.curActor.wallet) do 
    self:write(k.name .. "s: ", 2, i, k.color)
    self:write(k.char, 2 + #k.name + 3, i, k.color)
    self:write(tostring(v), #k.name + 4, i, k.color)
  end
end

function StatusPanel:statsToString(actor)
  local STR = actor:getStat("STR")
  local DEX = actor:getStat("DEX")
  local CON = actor:getStat("CON")
  local INT = actor:getStat("INT")
  local WIS = actor:getStat("INT")

  return self:statToString(STR) .. " " .. self:statToString(DEX) .. " " ..
         self:statToString(CON) .. " " .. self:statToString(INT) .. " " .. self:statToString(WIS)
end

function StatusPanel:statToString(stat)
  local s = tostring(stat)

  if #s == 1 then return "  " .. s end
  if #s == 2 then return " " .. s end
  return s
end

return StatusPanel
