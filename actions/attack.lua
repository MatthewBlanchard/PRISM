local Action = require "action"

function AttackEffect(source, position, dmg, hit)
  local t = 0

  local dirx, diry = position.x - source.x, position.y - source.y

  local char = "/"
  if dirx < 0 then
    char = "\\"
  elseif dirx == 0 then
    char = "|"
  end

  return function(dt, interface)
    local color
    if hit == false then
      color = {.6, .6, .6, 1}
    else
      color = {1, .1, .1, 1}
    end

    local dmgstring = tostring(dmg)
    local dmglen = string.len(dmgstring)

    interface:write(char, position.x, position.y, color)

    if hit then
      local xoffset = math.min(dirx * dmglen, 1)
      local xoffset = xoffset == 0 and 1 or xoffset
      interface:write(dmgstring, position.x + xoffset, position.y, color)
    end

    t = t + dt
    if t > .2 then return true end
  end
end

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
    local damage = target:getReaction(reactions.Damage)(target, self.owner, dmg)
    level:performAction(damage)
    level:addEffect(AttackEffect(self.owner.position, target.position, dmg, true))
    return
  end

  level:addEffect(AttackEffect(self.owner.position, target.position, dmg, false))
end

return Attack
