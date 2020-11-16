local Action = require "action"

local Attack = Action:extend()
Attack.name = "attack"
Attack.targets = {targets.Creature}

function Attack:__new(owner, targets, weapon)
  Action.__new(self, owner, targets)
  self.weapon = weapon
end

function Attack:perform(level)
  local weapon = self.weapon or self.owner.wielded
  local roll = self.owner:rollCheck(weapon.stat) + (weapon.bonus or 0)

  local target = self:getTarget(1)
  local dmg = ROT.Dice.roll(weapon.dice) + self.owner:getStatBonus(weapon.stat)

  self.time = weapon.time or 100
  if roll >= target:getAC() then
    self.hit = true
    local damage = target:getReaction(reactions.Damage)(target, {self.owner}, dmg)
    level:performAction(damage)
    return
  end

  level:addEffect(effects.DamageEffect(self.owner.position, target, dmg, false))
end

return Attack
