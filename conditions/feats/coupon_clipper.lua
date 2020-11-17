local Condition = require "condition"

local CouponClipper = Condition:extend()
CouponClipper.name = "Coupon Clipper"
CouponClipper.description = "25% off all items in the store! Please don't call my manager!"

CouponClipper:onAction(actions.Buy,
  function(self, level, actor, action)
    action.price = action.price - math.floor(action.price * 0.25)
  end
)

return CouponClipper
