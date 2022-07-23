local Condition = require "condition"

local BaffledBrute = Condition:extend()
BaffledBrute.name = "Baffled Brute"
BaffledBrute.description = "You are not very smart, but at least you're strong. +2 ATK -2 MGK"

function BaffledBrute:getATK()
  return 2
end

function BaffledBrute:getMGK()
  return -2
end

return BaffledBrute
