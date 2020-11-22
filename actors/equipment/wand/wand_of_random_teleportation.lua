local Actor = require "actor"
local Action = require "action"
local Condition = require "condition"
local Tiles = require "tiles"

local function PoofEffect(pos1)
  local t = 0
  return function(dt, interface)
    t = t + dt

    local color = {.4, .4, .4, 1}
    interface:writeOffset(Tiles["poof"], pos1.x, pos1.y, color)
    if t > .3 then return true end
  end
end

local Zap = actions.Zap:extend()
Zap.name = "zap"
Zap.targets = {targets.Item}

function Zap:perform(level)
  actions.Zap.perform(self, level)
  local target = self.targetActors[2]
  local position = self.owner.position

  local x, y = level:getRandomWalkableTile()
  self.owner.position = { x = x, y = y}
  level:addEffect(PoofEffect(self.owner.position))
end

local WandOfRandomTeleportation = Actor:extend()
WandOfRandomTeleportation.name = "Wand of Displacement"
WandOfRandomTeleportation.color = {0.1, 0.1, .7, 1}
WandOfRandomTeleportation.char = Tiles["wand_pointy"]
WandOfRandomTeleportation.stackable = false

WandOfRandomTeleportation.components = {
  components.Item(),
  components.Usable(),
  components.Wand{
    maxCharges = 5,
    zap = Zap
  },
  components.Cost{rarity = "uncommon"}
}

return WandOfRandomTeleportation
