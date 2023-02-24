local Actor = require "actor"
local Action = require "action"

local Product = Actor:extend()
Product.passable = false

local targetProduct = targets.Actor:extend()

function targetProduct:validate(owner, actor)
  return actor:is(actors.Product)
end

Product.components = {
  components.Sellable(),
  components.Usable({actions.Buy}, actions.Buy)
}

return Product
