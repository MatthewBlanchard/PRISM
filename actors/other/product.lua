local Actor = require "actor"
local Action = require "action"
local BuyPanel = require "panels.buy"

local Product = Actor:extend()
Product.passable = false

local targetProduct = targets.Actor:extend()

function targetProduct:validate(owner, actor)
  return actor:is(actors.Product)
end

local Buy = Action:extend()
Buy.name = "buy"
Buy.targets = {targetProduct}

function Buy:perform(level)
  local product = self.targetActors[1]

  if not product.forSale then
    product.forSale = true
    local itemPanel = BuyPanel(game.display, game.interface, product, 10, 20, 31, 31)
    game.interface:push(itemPanel)
    return
  end

  if self.owner:withdraw(product.currency, product.price) then
    level:performAction(self.owner:getAction(actions.Pickup)(self.owner, product.item), true)
    level:removeActor(product)
    if product.shopkeep then
      level:addEffect(product.soldEffect())
    end
  elseif product.shopkeep then
    level:addEffect(product.notSoldEffect())
  end
end

Product.components = {
  components.Sellable(),
  components.Usable({actions.Buy}, actions.Buy)
}

return Product
