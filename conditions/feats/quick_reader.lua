local Condition = require "condition"

local SpeedReader = Condition:extend()
SpeedReader.name = "Speed Reader"
SpeedReader.description = "Sometimes you read scrolls so fast they don't even notice. Read destroys scrolls half the time. Reading scrolls is faster."

SpeedReader:onAction(actions.Read,
  function(self, level, actor, action)
    action.time = action.time - 50
  end
)

SpeedReader:afterAction(actions.Read,
  function(self, level, actor, action)
    math.random()
  end
)


return SpeedReader
