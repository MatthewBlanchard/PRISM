local Component = require "component"

local Wand = Component:extend()

function Wand:__new(maxCharges)
  self.maxCharges = maxCharges
  self.charges = maxCharges
end

function Wand:initialize(actor)
  actor.charges = self.charges
  actor.maxCharges = self.maxCharges
  actor.modifyCharges = self.modifyCharges
end

function Wand:modifyCharges(n)
  print(self.charges)
  self.charges = math.min(math.max(self.charges + n, 0), self.maxCharges)

  local hasZap = self:getUseAction(actions.Zap)
  print(self.charges, hasZap, actions.Zap)
  if self.charges == 0 and hasZap then
    self.zap = hasZap
    print "yeet"
    self:removeUseAction(hasZap)
  elseif self.charges > 0 and not hasZap then
    self:addUseAction(actor.zap)
  end
end

return Wand
