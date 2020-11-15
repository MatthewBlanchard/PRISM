local Condition = require "condition"

local ModifyStats = Condition:extend()
ModifyStats.name = "stats"

function ModifyStats:__new(options)
  Condition.__new(self)
  self.stats = self.stats or options
end

function ModifyStats:getATK()
  return self.stats["ATK"] or 0
end

function ModifyStats:getMGK()
  return self.stats["MGK"] or 0
end

function ModifyStats:getPR()
  return self.stats["PR"] or 0
end

function ModifyStats:getMR()
  return self.stats["MR"] or 0
end

function ModifyStats:getAC()
  return self.stats["AC"] or 0
end

function ModifyStats:getMaxHP()
  return self.stats["maxHP"] or 0
end

return ModifyStats
