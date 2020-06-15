local Actor = require "actor"
local Action = require "action"
local Condition = require "condition"
local Tiles = require "tiles"

local Eat = Action:extend()
Eat.name = "eat"
Eat.targets = {targets.Item}

function Eat:perform(level)
  local heal = 2
  local target = self.targetActors[1]

  level:destroyActor(target)
  self.owner:setHP(self.owner:getHP() + heal)
  level:addEffect(effects.HealEffect(self.owner, heal))
end

local Parsnip = Actor:extend()
Parsnip.name = "Parsnip"
Parsnip.color = {0.97, 0.93, 0.55, 1}
Parsnip.emissive = false
Parsnip.char = Tiles["parsnip"]

Parsnip.components = {
  components.Item(),
  components.Usable{Eat}
}

return Parsnip