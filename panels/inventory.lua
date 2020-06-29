local Panel = require "panel"
local ItemPanel = require "panels.item"

local InventoryPanel = Panel:extend()
InventoryPanel.interceptInput = true

function InventoryPanel:__new(display, parent)
  Panel.__new(self, display, parent, 53, 12, 29, 11)
end

local function correctWidth(s, w)
  if string.len(s) < w then
    return s .. string.rep(" ", w - string.len(s))
  elseif string.len(s) > w then
    return string.sub(s, 1, w)
  else
    return s
  end
end

function InventoryPanel:draw()
  local actor = game.curActor
  local inventorySize = #actor.inventory
  local height = #actor.inventory + 3
  height = height % 2 == 0 and height + 1 or height

  self:drawBorders(nil, height)

  local w = string.len("Inventory                  ")
  self:write("Inventory                  ", 2, 2, {1, 1, 1, 1}, {.3, .3, .3, 1})
  if inventorySize > 0 then
    for i = 1, inventorySize do
      local inventoryString = i .. " " .. actor.inventory[i].name
      inventoryString = correctWidth(inventoryString, w)
      self:write(inventoryString, 2, 2 + i, {1, 1, 1, 1})
      self:write(actor.inventory[i].char, 3, 2 + i, actor.inventory[i].color)
    end

    if inventorySize < height - 3 then 
      self:write("                          ", 2, inventorySize + 3)
    end
  end
end

function InventoryPanel:update(dt)
  if #game.curActor.inventory == 0 then
    game.interface:pop()
  end
end

function InventoryPanel:handleKeyPress(keypress)
  Panel.handleKeyPress(self, keypress)

  local item = game.curActor.inventory[tonumber(keypress)]
  if item then
    game.interface:push(ItemPanel(self.display, self, item, self.x, self.y, self.w, self.h))
  end
end

return InventoryPanel
