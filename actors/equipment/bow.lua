local Actor = require "actor"
local Action = require "action"
local Tiles = require "tiles"

local BowTarget = targets.Actor:extend()
BowTarget.name = "BowTarget"
BowTarget.requirements = {components.Stats}
BowTarget.range = 9
BowTarget.positional = true

local Shoot = Action:extend()
Shoot.name = "shoot"
Shoot.targets = {targets.Item, BowTarget}

function Shoot:perform(level)
  if self.owner.hasItemType(self.owner, actors.Arrow) then 
    self.owner.removeItemType(self.owner, actors.Arrow)
  else 
    return
  end

  local target = self.targetActors[2]
  local damageAmount = ROT.Dice.roll("1d6")

  if targets.Creature:checkRequirements(target) then
    local damage = target:getReaction(reactions.Damage)(target, {self.owner}, damageAmount, self.targetActors[1])
    level:performAction(damage)
  end
end

local Bow = Actor:extend()
Bow.name = "bow"
Bow.char = Tiles["bow"]
Bow.color = {0.8, 0.5, 0.1, 1}

Bow.components = {
  components.Item(),
  components.Usable{Shoot}
}

return Bow