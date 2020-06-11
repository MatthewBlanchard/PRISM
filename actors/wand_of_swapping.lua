local Actor = require "actor"
local Action = require "action"
local Condition = require "condition"
local Tiles = require "tiles"

local function PoofEffect(pos1, pos2)
  local t = 0
  return function(dt, interface)
    t = t + dt

    local color = {.4, .4, .4, 1}
    interface:write(Tiles["poof"], pos1.x, pos1.y, color)
    interface:write(Tiles["poof"], pos2.x, pos2.y, color)
    if t > .3 then return true end
  end
end

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
  level:addEffect(PoofEffect(self.owner.position, target.position))
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