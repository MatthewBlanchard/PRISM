local ModifyStats = require "conditions.modifystats"

local Weight = ModifyStats:extend()
Weight.name = "weight"
Weight:setDuration(1500)
Weight.stats = {
	AC = 3
}

Weight:onAction(actions.Move,
  function(self, level, actor, action)
    action.time = action.time * 1.25
  end
)

return Weight