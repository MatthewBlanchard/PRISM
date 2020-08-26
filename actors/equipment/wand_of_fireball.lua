local Actor = require "actor"
local Action = require "action"
local Condition = require "condition"
local Tiles = require "tiles"
local Color = require "color"

local function FireballLightEffect(x, y, duration)
    local t = 0
    return function (dt)
        t = t + dt
        if t > duration then return nil end
        return x, y, Color.mul({0.8, 0.8, 0.1}, (1 - t/duration)*2)
    end
end

local ZapTarget = targets.Point:extend()
ZapTarget.name = "ZapTarget"
ZapTarget.range = 9

local Zap = Action:extend()
Zap.name = "zap"
Zap.fireballRange = 1
Zap.targets = {targets.Item, ZapTarget}

function Zap:perform(level)
  local target = self.targetActors[2]

  local fov, actors = level:getAOE("fov", target, self.fireballRange)
  local damage = ROT.Dice.roll("6d6")

  for _, actor in ipairs(actors) do
    if targets.Creature:checkRequirements(actor) then
      local damage = actor:getReaction(reactions.Damage)(actor, {self.owner}, damage, self.targetActors[1])
      level:performAction(damage)
    end
  end
  
  level:addEffect(effects.ExplosionEffect(fov, target, self.fireballRange))
  table.insert(level.temporaryLights, FireballLightEffect(target.x, target.y, 0.6))
end

local WandOfFireball = Actor:extend()
WandOfFireball.name = "Wand of Fireball"
WandOfFireball.description = "Blasts a small area with a ball of fire."
WandOfFireball.color = {1, 0.6, 0.2, 1}
WandOfFireball.char = Tiles["wand_gnarly"]
WandOfFireball.stackable = false

WandOfFireball.components = {
  components.Item(),
  components.Usable{Zap},
}

return WandOfFireball
