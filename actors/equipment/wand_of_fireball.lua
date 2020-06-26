local Actor = require "actor"
local Action = require "action"
local Condition = require "condition"
local Tiles = require "tiles"

local function FireballEffect(fov)
    local t = 0
    return function(dt, interface)
        t = t + dt

        for x, t in pairs(fov) do
            for y, _ in pairs(t) do
                local color = {.6, .2, .2, 1}
                interface:writeOffset(Tiles["poof"], x, y, color)
            end
        end
        
        if t > .3 then return true end
    end
end

local ZapTarget = targets.Point:extend()
ZapTarget.name = "ZapTarget"
ZapTarget.range = 9

local Zap = Action:extend()
Zap.name = "zap"
Zap.fireballRange = 4
Zap.targets = {targets.Item, ZapTarget}

function Zap:perform(level)
  local target = self.targetActors[2]

  local fov, actors = level:getAOE("fov", target, self.fireballRange)
  local damage = ROT.Dice.roll("3d6")

  for _, actor in ipairs(actors) do
    if targets.Creature:checkRequirements(actor) then
        local damage = actor:getReaction(reactions.Damage)(actor, {self.owner}, damage)
        level:performAction(damage)
    end
  end
  
  level:addEffect(FireballEffect(fov))
end

local WandOfFireball = Actor:extend()
WandOfFireball.name = "Wand of Fireball"
WandOfFireball.color = {0.1, 0.1, 1, 1}
WandOfFireball.char = Tiles["wand"]

WandOfFireball.components = {
  components.Item(),
  components.Usable{Zap},
}

return WandOfFireball
