local Actor = require "actor"
local Action = require "action"
local Condition = require "condition"
local Tiles = require "tiles"

local function clerp(start, finish, t)
    local c = {}
    for i = 1, 4 do
      if not start[i] or not finish[i] then break end
      c[i] = (1 - t) * start[i] + t * finish[i]
    end
  
    return c
end

local ambientColor = {.09, .09, .09}

local function FireballEffect(fov, origin, range)
    local t = 0
    local duration = .6
    local chars = {}
    chars[5] = 176
    chars[4] = 176
    chars[3] = 177
    chars[2] = 178
    chars[1] = 179
    chars[0] = 180

    local colors =
    {
    
    }
    return function(dt, interface)
        t = t + dt

        for x, yt in pairs(fov) do
            for y, _ in pairs(yt) do
                local distFactor = math.sqrt(math.pow(origin.x - x, 2) + math.pow(origin.y - y, 2))/(t/(duration/6)*range)
                local fadeFactor = math.min(t/duration, 1)
                local fade = math.max(distFactor, fadeFactor)
                local fade = math.min(fade + love.math.noise(x+t, y+t)/2, 1)
                local color = {0.8666, 0.4509, 0.0862}
                local char = chars[math.floor(fade * 5)]

                if fade < 0.5 then
                    local yellow = {0.8, 0.8, 0.1}
                    yellow = clerp(yellow, color, fade*2)
                    interface:writeOffset(char, x, y, yellow)
                elseif fade < 1 then
                    local grey = {0.3, 0.3, 0.3}
                    grey = clerp(color, grey, (fade - 0.5) * 2)
                    interface:writeOffset(char, x, y, grey)
                end
            end
        end
        
        if t > duration then return true end
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
        local damage = actor:getReaction(reactions.Damage)(actor, {self.owner}, damage)
        level:performAction(damage)
    end
  end
  
  level:addEffect(FireballEffect(fov, target, self.fireballRange))
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
