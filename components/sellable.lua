local Component = require "component"
local Tiles = require "tiles"

local Sellable = Component:extend()

function Sellable:initialize(actor)
  actor.setShopkeep = self.setShopkeep
  actor.setCurrency = self.setCurrency
  actor.setItem = self.setItem
end

function Sellable:setShopkeep(owner, actor)
  owner.shopkeep = actor 
  owner.soldEffect = effects.Character(actor.position.x, actor.position.y - 1, Tiles["bubble_heart"], {1, 1, 1}, 1)
end

function Sellable:setCurrency(owner, currency)
  owner.currency = currency
end

function Sellable:setItem(owner, item)
  owner.item = item
  owner.char = item.char
  owner.color = item.color
  owner.name = item.name
end

return Sellable 