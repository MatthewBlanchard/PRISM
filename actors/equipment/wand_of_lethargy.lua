local Actor = require "actor"
local Action = require "action"
local Condition = require "condition"
local Tiles = require "tiles"

local ZapTarget = targets.Actor:extend()
ZapTarget.name = "ZapTarget"
ZapTarget.requirements = {components.Stats}
ZapTarget.range = 6
ZapTarget.positional = true

local Zap = Action:extend()
Zap.name = "zap"
Zap.targets = {targets.Item, ZapTarget}

function Zap:perform(level)
  local target = self.targetActors[2]
  target:applyCondition(conditions.Lethargy())
end

local WandOfLethargy = Actor:extend()
WandOfLethargy.name = "Wand of Lethargy"
WandOfLethargy.color = {0.7, 0.1, 0.7, 1}
WandOfLethargy.char = Tiles["wand_pointy"]
WandOfLethargy.stackable = false

WandOfLethargy.components = {
  components.Item(),
  components.Usable{Zap},
}

return WandOfLethargy
