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

  if self.owner.inputControlled and not target.inputControlled then
    target.inputControlled = true
    self.owner.inputControlled = false
    self.owner.act = target.act
  end
end

local WandOfSoulExchange = Actor:extend()
WandOfSoulExchange.name = "Wand of Soul Exchange"
WandOfSoulExchange.color = {0.1, 0.1, 1, 1}
WandOfSoulExchange.char = "/"

WandOfSoulExchange.components = {
  components.Item(),
  components.Usable{Zap},
}

return WandOfSoulExchange
