local Condition = require "condition"
local Tiles = require "tiles"

local Recall = Condition:extend()
Recall.name = "recall"

Recall:setDuration(2000)

function Recall:setPosition(pos)
  self.pos = pos
end

function Recall:onDurationEnd(level, actor)
  if level:getCellPassable(self.pos.x, self.pos.y) then 
    actor.position = self.pos
    level:addEffect(effects.Character(self.pos.x, self.pos.y, Tiles["poof"], {.4, .4, .4}, 0.3))
  end
end

return Recall 
