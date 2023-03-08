local Reaction = require "reaction"

local Damage = Reaction:extend()
Damage.name = "damage"
Damage.silent = true

function Damage:__new(owner, dealer, damage)
  assert(dealer, "No dealer for damage reaction")
  assert(type(damage) == "number", "No damage for damage reaction")
  Reaction.__new(self, owner, nil)
  self.dealer = dealer
  self.damage = damage
end

function Damage:perform(level)
  self.owner.HP = math.max(self.owner.HP - self.damage, 0)

  local effects_system = level:getSystem("Effects")
  if effects_system then
    effects_system:addEffect(effects.DamageEffect(self.dealer.position, self.owner, self.damage, self.damage > 0))
  end
  if self.owner.HP == 0 then
    local die = self.owner:getReaction(reactions.Die)(self.owner, {self.dealer}, self.damage)
    level:performAction(die)
  end
end

return Damage
