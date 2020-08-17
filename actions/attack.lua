local Action = require "action"

local Attack = Action:extend()
Attack.name = "attack"
Attack.targets = {targets.Creature}

function Attack:perform(level)
  local roll = self.owner:rollCheck(self.owner.wielded.stat) + (self.owner.wielded.bonus or 0)
  local target = self:getTarget(1)
  local dmg = ROT.Dice.roll(self.owner.wielded.dice) + self.owner:getStatBonus(self.owner.wielded.stat)

  self.time = self.owner.wielded.time or 100
  if roll >= target:getAC() then
    self.hit = true
    local damage = target:getReaction(reactions.Damage)(target, {self.owner}, dmg)
    level:performAction(damage)
    return
  end

  level:addEffect(effects.DamageEffect(self.owner.position, target.position, dmg, false))
end

return Attack
