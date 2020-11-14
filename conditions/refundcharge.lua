local Condition = require "condition"

local RefundCharge = Condition:extend()
RefundCharge.name = "refundcharge"

function RefundCharge:__new(options)
  Condition.__new(self)
  self.chance = options.chance or 1
end

RefundCharge:afterAction(actions.Zap,
  function(self, level, actor, action)
    local wand = action:getTarget(1)

    if love.math.random() > self.chance then
      wand:modifyCharges(1)
    end
  end
)

return RefundCharge
