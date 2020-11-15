local Actor = require "actor"
local Action = require "action"
local Condition = require "condition"
local Tiles = require "tiles"

local ZapTarget = targets.Creature:extend()
ZapTarget.name = "ZapTarget"
ZapTarget.range = 6
ZapTarget.positional = false


local ZapWeapon = {
  stat = "MGK",
  name = "Wand of Blastin'",
  dice = "1d8",
}

local Zap = actions.Zap:extend()
Zap.name = "zap"
Zap.targets = {targets.Item, ZapTarget}

function Zap:perform(level)
  actions.Zap.perform(self, level)
  local target = self.targetActors[2]
  local attack = actions.Attack(self.owner, target, ZapWeapon)
  level:performAction(attack, true)
end

local WandOfBlastin = Actor:extend()
WandOfBlastin.name = "Wand of Blastin\'"
WandOfBlastin.description = "This thing packs a punch. Hope I'm not around when you start blastin'"
WandOfBlastin.color = {0.8, 0.8, 0.8, 1}
WandOfBlastin.char = Tiles["wand_pointy"]
WandOfBlastin.stackable = false

WandOfBlastin.components = {
  components.Item(),
  components.Usable(),
  components.Wand{
    maxCharges = 12,
    zap = Zap
  },
  components.Cost{rarity = "common"}
}

return WandOfBlastin
