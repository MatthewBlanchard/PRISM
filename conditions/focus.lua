local ModifyStats = require "conditions.modifystats"

local Focus = ModifyStats:extend()
Focus.name = "focus"
Focus:setDuration(1500)
Focus.stats = {
	AC = -3
}

Focus:onAction(actions.Attack,
  function(self, level, actor, action)
    action.criticalOn = action.criticalOn - 4
  end
)

return Focus

