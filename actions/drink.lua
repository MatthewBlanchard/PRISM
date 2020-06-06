local Action = require "action"

local Drink = Action:extend()
Drink.name = "drink"
Drink.targets = {targets.Item}

function Drink:__new(owner, target)
  Action.__new(self, owner, target)
  self.name = "drink"
end

function Drink:perform(level)
  local target = self.targetActors[1]
  target.name = "bottle"
  target.color = {.5, .5, .5, 1}
  target:removeComponent(components.Light)
  target:removeComponent(components.Usable)

  self.owner:setHP(self.owner:getHP() + 5)
end
