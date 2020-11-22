local Actor = require "actor"
local Vector2 = require "vector"
local Tiles = require "tiles"
local Condition = require "condition"

local SingOnEat = Condition:extend()
SingOnEat.name = "Sing on Eat"

SingOnEat:onAction(actions.Eat,
  function(self, level, actor, action)
    level:addEffect(effects.CharacterDynamic(action.owner, 0, -1, Tiles["bubble_music"], {1, 1, 1}, .5))
  end
):where(Condition.ownerIsTarget)

local Snip = Actor:extend()

Snip.char = Tiles["snip"]
Snip.name = "snip"
Snip.color = {0.97, 0.93, 0.55, 1}

Snip.innateConditions = {
  SingOnEat
}

Snip.components = {
  components.Sight{ range = 6, fov = true, explored = false },
  components.Move{speed = 100, passable = true},
  components.Stats{
    ATK = 0,
    MGK = 0,
    PR = 0,
    MR = 0,
    maxHP = 1,
    AC = 0
  },
  components.Item{stackable = true},
  components.Usable(),
  components.Edible{nutrition = 2},
  components.Aicontroller(),
  components.Animated()
}

local actUtil = components.Aicontroller
function Snip:act(level)
  local snip = actUtil.closestSeenActorByType(self, actors.Snip)
  local player = actUtil.closestSeenActorByType(self, actors.Player)
  local target = player or snip

  if target then
    if self:getRange("box", target) < 3 and target == player then
      level:addEffectAfterAction(effects.CharacterDynamic(self, 0, -1, Tiles["bubble_music"], {1, 1, 1}, .5))
    end
    return actUtil.crowdAround(self, target, true)
  end

  return actUtil.randomMove(self)
end

return Snip
