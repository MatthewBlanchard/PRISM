local Actor = require "actor"
local Action = require "action"

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

  if self.owner:withdraw(self.owner, product.currency) then
    level:performAction(game.curActor:getAction(actions.Pickup)(game.curActor, product.item))
    level:removeActor(product)
    if product.shopkeep then 
      level:addEffect(product.soldEffect)
    end
  else
  end
end

Product.components = {
  components.Sellable(),
  components.Usable({Buy}, Buy)
}

return Product