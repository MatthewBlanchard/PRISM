local Action = require "action"

local Zap = Action:extend()
Zap.name = "zap"
Zap.targets = {targets.Item}

function Zap:perform(level)
  local wand = self.targetActors[1]
  wand:modifyCharges(-1)
end

return Zap
