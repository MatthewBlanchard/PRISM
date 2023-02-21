local Action = require "action"

local AttackTarget = targets.Creature:extend()
AttackTarget:setRange(1)

local Attack = Action:extend()
Attack.name = "attack"
Attack.targets = {AttackTarget}

function Attack:__new(owner, defender, weapon)
  Action.__new(self, owner, { defender })
  self.weapon = weapon or owner:getComponent(components.Attacker).wielded
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

  local defender = self:getTarget(1)
  local dmg = ROT.Dice.roll(weapon.dice) + self.owner:getStatBonus(weapon.stat)

  local critical = naturalRoll >= self.criticalOn
  if roll >= defender:getAC() or critical then
    self.hit = true
    if critical then
      dmg = dmg * 2
    end

    print("OWNER", self.owner)
    local damage = defender:getReaction(reactions.Damage)(defender, {self.owner}, dmg)

    level:performAction(damage)
    return
  end

  level:addEffect(effects.DamageEffect(self.owner.position, defender, dmg, false))
end

return Attack
