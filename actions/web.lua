local Action = require "action"
local Tiles = require "tiles"

local Web = Action:extend()
Web.name = "web"
Web.targets = {targets.Creature}

function Web:perform(level)
  local creature = self.targetActors[1]
  creature:applyCondition(conditions.Slowed)
  level:addEffect(effects.CharacterDynamic(creature, 0, 0, Tiles["web"], {1, 1, 1}, .5))
end

return Web
