local Panel = require "panel"
local Colors = require "colors"

local StatusPanel = Panel:extend()

function StatusPanel:__new(display, parent)
  local x, y = game.display:getWidth() - 20, game.display:getHeight()
  Panel.__new(self, display, parent, x, 1, 21, 9)
end

function StatusPanel:draw()
  self:clear()
  self:drawBorders()
  local hpPercentage = game.curActor.HP / game.curActor:getMaxHP()
  local barLength = math.floor(19 * hpPercentage)
  local hpString = tostring(game.curActor.HP) .. "/" .. tostring(game.curActor:getMaxHP()) .. " HP"

  for i = 1, 19 do
    local c = string.sub(hpString, i, i)
    c = c == "" and " " or c

    local bg = barLength >= i and {.3, .3, .3, 1} or {.2, .1, .1, 1}
    self:write(c, i + 1, 3, {.75, .75, .75, 1}, bg)
  end

  local statbonus = game.curActor:getStatBonus(game.curActor.wielded.stat)
  self:write(game.curActor.wielded.name, 2, 4, {.75, .75, .75, 1})
  self:write("AC: " .. game.curActor:getAC(), 2, 5, {.75, .75, .75, 1})

  local i = 7
  for k, v in pairs(game.curActor.wallet) do
    self:write(k.name .. "s: ", 2, i, k.color)
    self:write(k.char, 2 + #k.name + 3, i, k.color)
    self:write(tostring(v), #k.name + 4, i, k.color)
    i = i + 1
  end
end

function StatusPanel:statsToString(actor)
  local ATK = actor:getStat("ATK")
  local MGK = actor:getStat("MGK")
  local PR = actor:getStat("PR")
  local MR = actor:getStat("MR")

  return self:statToString(ATK) .. " " .. self:statToString(MGK) .. " " ..
         self:statToString(PR) .. " " .. self:statToString(MR)
end

function StatusPanel:statToString(stat)
  local s = tostring(stat)

  if #s == 1 then return "  " .. s end
  if #s == 2 then return " " .. s end
  return s
end

return StatusPanel
