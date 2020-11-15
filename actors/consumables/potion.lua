local Actor = require "actor"
local Action = require "action"
local Condition = require "condition"
local Tiles = require "tiles"

local Drink = actions.Drink:extend()
Drink.name = "drink"
Drink.targets = {targets.Item}

function Drink:perform(level)
  actions.Drink.perform(self, level)

  local heal = self.owner:getReaction(reactions.Heal)
  level:performAction(heal(self.owner, {self.owner}, 5))
end

local Potion = Actor:extend()
Potion.name = "Potion of Healing"
Potion.description = "Heals you for 5 HP."
Potion.color = {1, 0, 0, 1}
Potion.emissive = true
Potion.char = Tiles["potion"]
Potion.lightEffect = components.Light.effects.pulse({ 0.3, 0.0, 0.0, 1 }, 3, .5)

Potion.components = {
  components.Light{
    color = { 1, 0.0, 0.0, 1},
    intensity = 1,
    effect = Potion.lightEffect
  },
  components.Item({stackable = true}),
  components.Usable(),
  components.Drinkable{drink = Drink},
  components.Cost()
}

return Potion
