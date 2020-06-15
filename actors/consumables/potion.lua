local Actor = require "actor"
local Action = require "action"
local Condition = require "condition"
local Tiles = require "tiles"

local Drink = Action:extend()
Drink.name = "drink"
Drink.targets = {targets.Item}

function Drink:perform(level)
  local heal = 5
  local target = self.targetActors[1]

  level:destroyActor(target)
  self.owner:setHP(self.owner:getHP() + heal)
  level:addEffect(effects.HealEffect(self.owner, heal))
end

local Potion = Actor:extend()
Potion.name = "Potion of Healing"
Potion.color = {1, 0, 0, 1}
Potion.emissive = true
Potion.char = Tiles["potion"]
Potion.lightEffect = components.Light.effects.pulse({ 0.3, 0.0, 0.0, 1 }, 3, .5)

Potion.components = {
  components.Light({ 0.1, 0.0, 0.0, 1}, 3, Potion.lightEffect),
  components.Item(),
  components.Usable{Drink}
}

return Potion
