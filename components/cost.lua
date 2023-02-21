local Component = require "component"

local Cost = Component:extend()
Cost.name = "Cost"
Cost.requirements = {components.Item}

local dummy = {}
function Cost:__new(options)
  options = options or dummy
  self.rarity = options.rarity or "common"
  self.tags = options.tags or {}
  self.cost = options.cost
end

function Cost:initialize(actor)
  self.cost = self.cost or Loot.generateBasePrice(actor)
end

return Cost
