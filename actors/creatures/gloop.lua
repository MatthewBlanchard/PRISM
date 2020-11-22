local Actor = require "actor"
local Vector2 = require "vector"
local Tiles = require "tiles"
local Condition = require "condition"

local Gloop = Actor:extend()

Gloop.char = Tiles["gloop"]
Gloop.name = "gloop"
Gloop.color = {90 / 230, 161 / 230, 74 / 230}

local Explode = Condition:extend()
Explode.range = 1
Explode.damage = "1d4"
Explode.color = {90 / 230, 161 / 230, 74 / 230}

Explode:afterAction(actions.Throw,
  function(self, level, actor, action)
    local fov, actors = level:getAOE("fov", actor.position, Explode.range)
  	local damage = ROT.Dice.roll(self.damage) + 1

  	for _, a in ipairs(actors) do
  	  if targets.Creature:checkRequirements(a) then
  	    local damage = a:getReaction(reactions.Damage)(a, {action.owner}, damage, actor)
  		  level:performAction(damage)
  	  end
  	end

  	level:addEffect(effects.ExplosionEffect(fov, actor.position, Explode.range, Explode.color))
  	table.insert(level.temporaryLights, effects.LightEffect(actor.position.x, actor.position.y, 0.6, Explode.color, 2))
  	level:destroyActor(actor)
  end
):where(Condition.ownerIsTarget)


Gloop.components = {
  components.Sight{ range = 2, fov = true, explored = false },
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
  components.Aicontroller(),
  components.Animated()
}

Gloop.innateConditions = {Explode()}


local actUtil = components.Aicontroller
function Gloop:act(level)
  for _, actor in ipairs(self.seenActors) do
    if actor:is(actors.Player) then
      level:addEffectAfterAction(effects.CharacterDynamic(self, 0, -1, Tiles["bubble_lines"], {1, 1, 1}, .5))
      self._meanderDirection = nil
      return actUtil.moveAway(self, actor)
    end
  end

  if not self._meanderDirection or
    not actUtil.isPassable( self, self.position + self._meanderDirection)
  then
    self._meanderDirection = actUtil.getPassableDirection(self)
  end

  return actUtil.move(self, self._meanderDirection)
end

return Gloop
