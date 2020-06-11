local Actor = require "actor"
local Action = require "action"
local Condition = require "condition"

local ZapTarget = targets.Target()
ZapTarget.name = "ZapTarget"
ZapTarget.requirements = {components.Stats}
ZapTarget.range = 6

local Zap = Action:extend()
Zap.name = "zap"
Zap.targets = {targets.Item, ZapTarget}

function Zap:perform(level)
  local target = self.targetActors[2]
  local position = self.owner.position

  self.owner.position, target.position = target.position, self.owner.position
end

local WandOfSwapping = Actor:extend()
WandOfSwapping.name = "Wand of Swapping"
WandOfSwapping.color = {0.1, 0.1, 1, 1}
WandOfSwapping.char = "/"

WandOfSwapping.components = {
  components.Item(),
  components.Usable{Zap},
}

return WandOfSwapping
