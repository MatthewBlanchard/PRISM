local Actor = require "actor"
local Action = require "action"
local Condition = require "condition"
local Tiles = require "tiles"
local Vector2 = require "vector"

local Zap = actions.Zap:extend()
Zap.name = "zap"
Zap.targets = {targets.Item}

function Zap:perform(level)
  actions.Zap.perform(self, level)
  local target = self.targetActors[2]
  local position = self.owner.position

  local x, y = level:getRandomWalkableTile()
  self.owner.position = Vector2(x, y)
  level:addEffect(effects.Character(x, y, Tiles["poof"], {.4, .4, .4}, 0.3))
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
