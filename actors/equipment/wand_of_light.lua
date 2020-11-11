local Actor = require "actor"
local Action = require "action"
local Condition = require "condition"
local Tiles = require "tiles"

-- Give the orb a lifetime
local customLifetime = conditions.Lifetime:extend()
customLifetime:setDuration(3000)

-- The light actor
-- Not super reusable so we define the light actor here.
local Orb = Actor:extend()
Orb.char = Tiles["pointy_poof"]
Orb.name = "Orb of light"

Orb.components = {
  components.Light({ 0.8, 0.8, 0.866, 1}, 2.5, lightEffect),
}

Orb.innateConditions = { customLifetime }

-- Let's get our zap target going.
local ZapTarget = targets.Point:extend()
ZapTarget.name = "ZapTarget"
ZapTarget.range = 6

-- Define our custom zap
local Zap = actions.Zap:extend()
Zap.name = "zap"
Zap.targets = {targets.Item, ZapTarget}

function Zap:perform(level)
  actions.Zap.perform(self, level)

  local target = self.targetActors[2]
  local orb = Orb()
  orb.position = target

  level:addActor(orb)
end

-- Actual item definition all the way down here
local WandOfLight = Actor:extend()
WandOfLight.name = "Wand of Lethargy"
WandOfLight.color = {0.7, 0.1, 0.7, 1}
WandOfLight.char = Tiles["wand_pointy"]
WandOfLight.stackable = false

WandOfLight.components = {
  components.Item(),
  components.Usable{Zap},
  components.Wand(5)
}

return WandOfLight
