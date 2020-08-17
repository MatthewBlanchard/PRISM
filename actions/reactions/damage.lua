local Reaction = require "reaction"

local Damage = Reaction:extend()
Damage.name = "damage"
Damage.silent = true
Damage.targets = {targets.Creature}-- dealer

function Damage:__new(owner, targets, damage)
  Reaction.__new(self, owner, targets)
  self.dealer = targets[1]
  self.damage = damage
end

function Damage:perform(level)
  self.owner.HP = math.max(self.owner.HP - self.damage, 0)
  level:addEffect(effects.DamageEffect(self.dealer.position, self.owner.position, self.damage, true))
  if self.owner.HP == 0 then
    local die = self.owner:getReaction(reactions.Die)(self.owner, {self.dealer}, self.damage)
    level:performAction(die)
  end
end

return Damage
