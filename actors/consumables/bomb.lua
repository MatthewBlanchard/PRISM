local Actor = require "actor"
local Condition = require "condition"
local Color = require "color"
local Tiles = require "tiles"

local function BombLightEffect(x, y, duration)
    local t = 0
    return function (dt)
        t = t + dt
        if t > duration then return nil end
        return x, y, Color.mul({0.8, 0.8, 0.1}, (1 - t/duration)*2)
    end
end

local Explode = Condition:extend()
Explode.range = 2

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
	table.insert(level.temporaryLights, BombLightEffect(actor.position.x, actor.position.y, 0.6))
	level:destroyActor(actor)
  end
)

local Bomb = Actor:extend()
Bomb.name = "Bomb"
Bomb.char = Tiles["bomb"]
Bomb.color = {0.4, 0.4, 0.4, 1}
Bomb.description = "A simple key. You wonder what it unlocks."
Bomb.innateConditions = {Explode()}

Bomb.components = {
  components.Item({stackable = true})
}

return Bomb