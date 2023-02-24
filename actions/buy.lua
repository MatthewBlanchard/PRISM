local Action = require "action"

local targetProduct = targets.Actor:extend()

function targetProduct:validate(owner, actor)
  return actor:is(actors.Product)
end

local Buy = Action:extend()
Buy.name = "buy"
Buy.targets = {targetProduct}

function Buy:__new(owner, targets)
  Action.__new(self, owner, targets)
  self.product = self:getTarget(1)
end

function Buy:perform(level)
  local wallet_component = self.owner:getComponent(components.Wallet)
  local sellable_component = self.product:getComponent(components.Sellable)
  
  assert(sellable_component, "Product is not a Sellable!")
  
  if wallet_component and wallet_component:withdraw(sellable_component.currency, sellable_component.price) then
    level:performAction(self.owner:getAction(actions.Pickup)(self.owner, sellable_component.item), true)
    level:removeActor(self.product)

    if sellable_component.shopkeep then
      level:addEffect(self.product.soldEffect())
    end
  elseif sellable_component.shopkeep then
    level:addEffect(self.product.notSoldEffect())
  end
end

return Buy
