local Action = require "action"

local Attack = Action:extend()
Attack.name = "attack"
Attack.targets = {targets.Creature}

function Attack:__new(owner, targets, weapon)
  Action.__new(self, owner, targets)
  self.weapon = weapon or owner.wielded
  self.time = self.weapon.time or 100
  self.damageBonus = 0
  self.attackBonus = 0
  self.criticalOn = 20
end

function Attack:perform(level)
  local weapon = self.weapon
  local weaponBonus = weapon.bonus or 0
  local bonus = self.owner:getStatBonus(weapon.stat) + weaponBonus + self.attackBonus
  local naturalRoll = self.owner:rollCheck(weapon.stat)
  local roll = naturalRoll + bonus

  local target = self:getTarget(1)
  local dmg = ROT.Dice.roll(weapon.dice) + self.owner:getStatBonus(weapon.stat)

  local critical = naturalRoll >= self.criticalOn
  if roll >= target:getAC() or critical then
    self.hit = true
    if critical then
      dmg = dmg * 2
    end
    local damage = target:getReaction(reactions.Damage)(target, {self.owner}, dmg)

    level:performAction(damage)
    return
  end

  level:addEffect(effects.DamageEffect(self.owner.position, target, dmg, false))
end

return Attack
