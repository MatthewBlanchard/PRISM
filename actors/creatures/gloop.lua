local Actor = require "actor"
local Vector2 = require "vector"
local Tiles = require "tiles"
local Condition = require "Condition"

local Gloop = Actor:extend()

Gloop.char = Tiles["gloop"]
Gloop.name = "gloop"
Gloop.color = {90 / 230, 161 / 230, 74 / 230}

local Explode = Condition:extend()
Explode.range = 2
Explode.color = {90 / 230, 161 / 230, 74 / 230}

Explode:afterAction(actions.Throw,
  function(self, level, actor, action)
    local fov, actors = level:getAOE("fov", actor.position, Explode.range)
	local damage = ROT.Dice.roll("6d6")

	for _, a in ipairs(actors) do
	  if targets.Creature:checkRequirements(a) then
	    local damage = a:getReaction(reactions.Damage)(a, {action.owner}, damage, actor)
		level:performAction(damage)
	  end
	end

	level:addEffect(effects.ExplosionEffect(fov, actor.position, Explode.range))
	table.insert(level.temporaryLights, effects.LightEffect(actor.position.x, actor.position.y, 0.6, Explode.color))
	level:destroyActor(actor)
  end
):where(Condition.ownerIsTarget)


Gloop.components = {
  components.Sight{ range = 2, fov = true, explored = false },
  components.Move(120, true),
  components.Item{stackable = true},
  components.Aicontroller()
}

Gloop.innateConditions = {Explode()}


local actUtil = components.Aicontroller
function Gloop:act(level)
  for _, actor in ipairs(self.seenActors) do
    if actor:is(actors.Player) then
      level:addEffect(effects.CharacterDynamic(self, 0, -1, Tiles["bubble_lines"], {1, 1, 1}, .5))
      return actUtil.moveAway(self, actor)
    end
  end

  return actUtil.randomMove(level, self)
end

return Gloop
