local Actor = require "actor"
local Condition = require "condition"
local Color = require "color"
local Tiles = require "tiles"

local Explode = Condition:extend()
Explode.range = 4
Explode.color = {0.8 * 3, 0.8 * 3, 0.1 * 3}

Explode:afterAction(actions.Throw,
  function(self, level, actor, action)
    local fov, actors = level:getAOE("fov", actor.position, Explode.range)
	local damage = ROT.Dice.roll("6d6")

  level:destroyActor(actor)
  table.insert(level.temporaryLights, effects.LightEffect(actor.position.x, actor.position.y, 0.6, Explode.color))
  level:addEffect(effects.ExplosionEffect(fov, actor.position, Explode.range))

  level:suppressEffects()
  	for _, a in ipairs(actors) do
  	  if targets.Creature:checkRequirements(a) then
  	    local damage = a:getReaction(reactions.Damage)(a, {action.owner}, damage, actor)
  		level:performAction(damage)
  	  end
  	end
  level:resumeEffects()

  end
):where(Condition.ownerIsTarget)

local Bomb = Actor:extend()
Bomb.name = "Bomb"
Bomb.char = Tiles["bomb"]
Bomb.color = {0.4, 0.4, 0.4, 1}
Bomb.description = "A simple key. You wonder what it unlocks."
Bomb.innateConditions = {Explode()}

Bomb.components = {
  components.Item({stackable = true}),
  components.Cost{
    cost = 7,
    rarity = "uncommon"
  }
}

return Bomb
