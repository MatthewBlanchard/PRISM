local Actor = require "actor"
local Action = require "action"
local Condition = require "condition"
local Tiles = require "tiles"

local Drink = actions.Drink:extend()
Drink.name = "drink"
Drink.targets = {targets.Item}

function Drink:perform(level)
  actions.Drink.perform(self, level)
  local recall = conditions.Recall()
  recall:setPosition(self.owner.position)
  self.owner:applyCondition(recall)
end

local Potion = Actor:extend()
Potion.name = "Potion of Recall"
Potion.color = {0.5, 0.5, 0.5, 1}
Potion.char = Tiles["potion"]

Potion.components = {
  components.Item({stackable = true}),
  components.Usable(),
  components.Drinkable{ drink = Drink },
  components.Cost()
}

return Potion