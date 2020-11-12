local Action = require "action"
local Eat = Action:extend()
Eat.name = "eat"
Eat.targets = {targets.Item}

function Eat:perform(level)
  local food = self:getTarget(1)

  level:destroyActor(food)
  self.owner:setHP(self.owner:getHP() + food.nutrition)
  level:addEffect(effects.HealEffect(self.owner, food.nutrition))
end

return Eat
