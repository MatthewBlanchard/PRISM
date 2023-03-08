local Action = require "action"
local Tiles = require "tiles"

local WebTarget = targets.Creature:extend()
WebTarget:setRange(4)

local Web = Action:extend()
Web.name = "web"
Web.targets = {WebTarget}

function Web:perform(level)
  local creature = self:getTarget(1)

  creature:applyCondition(conditions.Slowed)

  local effects_system = level:getSystem("Effects")
  if effects_system then
    effects_system:addEffect(effects.CharacterDynamic(creature, 0, 0, Tiles["web"], {1, 1, 1}, .5))
  end
end

return Web
