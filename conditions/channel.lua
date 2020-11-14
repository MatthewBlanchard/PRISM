local Condition = require "condition"

local Channel = Condition:extend()
Channel.name = "channel"

Channel:afterAction(actions.Zap,
  function(self, level, actor, action)
    local wand = action:getTarget(1)

    local fov, actors = level:getAOE("fov", actor.position, 1)

    local damage = ROT.Dice.roll("1d4")

    for _, other in ipairs(actors) do
      if other ~= actor then
        if targets.Creature:checkRequirements(other) then
          local damage = other:getReaction(reactions.Damage)(actor, {self.owner}, damage, wand)
          level:performAction(damage)
        end
      end
    end

    level:addEffect(effects.ExplosionEffect(fov, actor.position, 1, {1, 1, 1}))
  end
)

return Channel
