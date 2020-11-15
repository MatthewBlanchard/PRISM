local Actor = require "actor"
local Action = require "action"
local Condition = require "condition"
local Tiles = require "tiles"

-- The light actor
-- Not super reusable so we define the light actor here.
local Orb = Actor:extend()
Orb.char = Tiles["pointy_poof"]
Orb.name = "Orb of light"

Orb.components = {
  components.Light{
    color = { 0.8, 0.8, 0.866, 1 },
    intensity = 2.5
  },
  components.Lifetime{ duration = 3000 }
}

-- Let's get our zap target going.
local ZapTarget = targets.Point:extend()
ZapTarget.name = "ZapTarget"
ZapTarget.range = 6

-- Define our custom zap
local Zap = actions.Zap:extend()
Zap.name = "zap"
Zap.targets = {targets.Item, ZapTarget}
Zap.aoeRange = 3

function Zap:perform(level)
  actions.Zap.perform(self, level)

  local target = self.targetActors[2]
  local orb = Orb()
  orb.position = target
  level:addActor(orb)

  local fov, actors = level:getAOE("fov", target, self.aoeRange)

  for _, actor in ipairs(actors) do
    if targets.Creature:checkRequirements(actor) then
      if level:isScheduled(actor) then
        level:addEffect(effects.CharacterDynamic(actor, 0, -1, Tiles["bubble_stun"], {1, 1, 1}, .5))
        level:addScheduleTime(actor, 600)
      end
    end
  end
end

-- Actual item definition all the way down here
local WandOfLight = Actor:extend()
WandOfLight.name = "Wand of Light"
WandOfLight.color = {0.7, 0.7, 0.7, 1}
WandOfLight.char = Tiles["wand_pointy"]
WandOfLight.stackable = false

WandOfLight.components = {
  components.Item(),
  components.Usable(),
  components.Wand{
    maxCharges = 5,
    zap = Zap
  },
  components.Cost{rarity = "common"}
}

return WandOfLight
