local Actor = require "actor"
local Action = require "action"
local Condition = require "condition"
local Tiles = require "tiles"

local Drink = Action:extend()
Drink.name = "drink"
Drink.targets = {targets.Item}

function Drink:perform(level)
  local target = self.targetActors[1]

  level:destroyActor(target)
  self.owner:applyCondition(conditions.Rage())
end

local Potion = Actor:extend()
Potion.name = "Potion of Anger"
Potion.color = {0.5, 0.5, 0.5, 1}
Potion.char = Tiles["potion"]

Potion.components = {
  components.Item(),
  components.Usable{Drink}
}

return Potion