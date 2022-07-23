local Panel = require "panel"
local ItemPanel = require "panels.item"

local InventoryPanel = Panel:extend()
InventoryPanel.interceptInput = true
InventoryPanel.bg = { .09, .09, .09 }

function InventoryPanel:__new(display, parent)
  Panel.__new(self, display, parent, 47, 12, 35, 11)
  self.items = {}
  self.indices = {}

  local count = 0
  for i, v in ipairs(game.curActor.inventory) do
    local meta = getmetatable(v)

    if not v.stackable then
      self.items[v] = { v }
      count = count + 1
    elseif self.items[meta] then
      table.insert(self.items[meta], v)
    else
      count = count + 1
      self.items[meta] = { v }
    end
  end

  self.h = self:correctHeight(count + 3)
end

function InventoryPanel:draw()
  local actor = game.curActor

  self:clear()
  self:drawBorders()

  local title = self:correctWidth("Inventory", self.w - 2)
  local w = string.len(title)
  self:write(title, 2, 2, { 1, 1, 1, 1 }, { .3, .3, .3, 1 })

  local i = 1
  for meta, list in pairs(self.items) do

    local inventoryString = self:correctWidth(i .. " " .. meta.name, self.w - 5)
    inventoryString = inventoryString .. (#list > 1 and (" x" .. #list) or "")
    self:write(inventoryString, 2, 2 + i, { 1, 1, 1, 1 })
    self:write(meta.char, 3, 2 + i, meta.color)
    self.indices[i] = list[1]
    i = i + 1
  end
end

function InventoryPanel:update(dt)
  if #game.curActor.inventory == 0 then
    game.interface:pop()
  end
end

function InventoryPanel:handleKeyPress(keypress)
  Panel.handleKeyPress(self, keypress)

  local item = self.indices[tonumber(keypress)]
  if item then
    game.interface:push(ItemPanel(self.display, self, item, self.x, self.y, self.w, self.h))
  end
end

return InventoryPanel
