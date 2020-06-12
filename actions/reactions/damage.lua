local Reaction = require "reaction"

local Damage = Reaction:extend()
Damage.name = "damage"
Damage.silent = true
Damage.targets = {targets.Creature}-- dealer

function Damage:__new(owner, targets, damage, dealer)
  Reaction.__new(self, owner, targets)
  self.dealer = dealer
  self.damage = damage
end

function Damage:perform(level)
  self.owner.HP = math.max(self.owner.HP - self.damage, 0)
  if self.owner.HP == 0 then
    local die = self.owner:getReaction(reactions.Die)(self.owner, damage, dealer)
    level:performAction(die)
  end
end

return Damage
