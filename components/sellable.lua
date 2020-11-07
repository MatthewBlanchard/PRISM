local Component = require "component"
local Tiles = require "tiles"

local Sellable = Component:extend()

function Sellable:initialize(actor)
  actor.setShopkeep = self.setShopkeep
  actor.setPrice = self.setPrice
  actor.setItem = self.setItem
end

function Sellable:setShopkeep(actor)
  self.shopkeep = actor 
  self.soldEffect = effects.Character(actor.position.x, actor.position.y - 1, Tiles["bubble_heart"], {1, 1, 1}, 1)
end

function Sellable:setPrice(currency, price)
  self.currency = currency
  self.price = price
end

function Sellable:setItem(item)
  self.item = item
  self.char = item.char
  self.color = item.color
  self.name = item.name
end

return Sellable 