local Reaction = require "reaction"

local Heal = Reaction:extend()
Heal.name = "heal"
Heal.silent = true
Heal.targets = {targets.Creature} -- dealer

function Heal:__new(owner, targets, heal, source, type)
  Reaction.__new(self, owner, targets)
  self.healer = targets[1]
  self.heal = heal
  self.source = source
  if not self.source then
    print("No heal source for: " .. self.healer.name .. " against " .. owner.name)
  end
end

function Heal:perform(level)
  self.owner.HP = math.min(self.owner.HP + self.heal, self.owner:getMaxHP())
  level:addEffect(effects.HealEffect(self.owner, self.heal))
end

return Heal
