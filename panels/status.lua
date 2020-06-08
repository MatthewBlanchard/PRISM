local Panel = require "panel"

local StatusPanel = Panel:extend()

function StatusPanel:__new(display, parent)
  Panel.__new(self, display, parent, 2, 47, 15, 3)
end

function StatusPanel:draw()
  local hpPercentage = game.curActor.HP / game.curActor.maxHP
  local barLength = math.floor(15 * hpPercentage)
  local hpString = tostring(game.curActor.HP) .. "/" .. tostring(game.curActor.maxHP) .. " HP"

  for i = 1, 15 do
    local c = string.sub(hpString, i, i)
    c = c == "" and " " or c

    local bg = barLength >= i and {.3, .3, .3, 1} or {.2, .1, .1, 1}
    self:write(c, i, 1, {.6, .6, .6, 1}, bg)
  end

  local statbonus = game.curActor:getStatBonus(game.curActor.attack.stat)
  self:write(game.curActor.attack.name, 1, 2, {.5, .5, .5, 1})
  self:write("AC: " .. game.curActor:getAC(), 1, 3, {.5, .5, .5, 1})
end

return StatusPanel
