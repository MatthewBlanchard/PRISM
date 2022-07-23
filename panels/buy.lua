local ItemPanel = require "panels.item"

local BuyPanel = ItemPanel:extend()

function BuyPanel:__new(display, parent, product, x, y, w, h)
  ItemPanel.__new(self, display, parent, product.item, x, y, w, h)
  self.product = product
end

function BuyPanel:draw()
  ItemPanel.draw(self)
  local x = self.w - 2
  self:write(tostring(self.product.price), x, 2, self.product.currency.color)
  self:write(self.product.currency.char, x + 1, 2, self.product.currency.color)
end

function BuyPanel:handleKeypress(key)
  game.interface:handleKeypress(key)
end

return BuyPanel
