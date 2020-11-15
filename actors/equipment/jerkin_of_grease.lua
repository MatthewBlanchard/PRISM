local Actor = require "actor"
local Condition = require "condition"
local Tiles = require "tiles"

local FreedomOfMovement = Condition:extend()
FreedomOfMovement.name = "Swiftness"
FreedomOfMovement.description = "Your actions take 25% less time."

FreedomOfMovement:setTime(actions.Move,
  function(self, level, actor, action)
    print(action.time)
    action.time = math.min(action.time, 85)
    print(action.time)
  end
)

local LeatherArmor = Actor:extend()
LeatherArmor.char = Tiles["armor"]
LeatherArmor.name = "Jerkin of Grease"
LeatherArmor.desc = "Nothing can slow you down with this armor on. You also move a bit faster."

LeatherArmor.components = {
  components.Item(),
  components.Equipment{
    slot = "body",
    effects = {
      conditions.Modifystats{
        AC = 2
      },
      FreedomOfMovement()
    }
  }
}

return LeatherArmor
