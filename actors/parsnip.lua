local Actor = require "actor"
local Action = require "action"
local Condition = require "condition"
local Tiles = require "tiles"

local function DrinkEffect(actor, heal)
  local t = 0
  local lastflip = 9
  return function(dt, interface)
    t = t + dt

    local color = {.1, 1, .1, 1}
    interface:write(Tiles["heal"], actor.position.x, actor.position.y, color)
    interface:write(tostring(heal), actor.position.x + 1, actor.position.y, color)
    if t > .5 then return true end
  end
end

local Eat = Action:extend()
Eat.name = "eat"
Eat.targets = {targets.Item}

function Eat:__new(owner, target)
  Action.__new(self, owner, target)
  self.name = "eat"
end

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