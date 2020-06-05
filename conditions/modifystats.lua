local Condition = require "condition"

local ModifyStats = Condition:extend()

function ModifyStats:__new(options)
	Condition.__new(self)
	self.stats = self.stats or options
end

function ModifyStats:getSTR()
	return self.stats["STR"] or 0
end

function ModifyStats:getDEX()
	return self.stats["DEX"] or 0
end

function ModifyStats:getINT()
	return self.stats["INT"] or 0
end

function ModifyStats:getCON()
	return self.stats["CON"] or 0
end

function ModifyStats:getAC()
	return self.stats["AC"] or 0
end

function ModifyStats:getMaxHP()
	return self.stats["maxHP"] or 0
end

return ModifyStats
