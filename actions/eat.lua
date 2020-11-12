local Action = require "action"
local Consume = require "actions/consume"

local Eat = Consume:extend()
Eat.name = "eat"
Eat.targets = {targets.Item}

function Eat:perform(level)
  Consume.perform(self, level)

  local eater = self.owner
  local food = self:getTarget(1)
  local heal = self.owner:getReaction(reactions.Heal)
  level:performAction(heal(eater, {eater}, food.nutrition))
end

return Eat
