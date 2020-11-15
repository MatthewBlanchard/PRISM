local Actor = require "actor"
local Condition = require "condition"
local Tiles = require "tiles"

local FreedomOfMovement = Condition:extend()
FreedomOfMovement.name = "FreedomOfMovement"
FreedomOfMovement.description= "You have an 85 move speed and can't be reduced."

FreedomOfMovement:setTime(actions.Move,
  function(self, level, actor, action)
    action.time = math.min(action.time, 85)
  end
)

local JerkinOfGrease = Actor:extend()
JerkinOfGrease.char = Tiles["armor"]
JerkinOfGrease.name = "Mantle of Broken Chains"
JerkinOfGrease.description = "Nothing can slow you down with this armor on. You also move a bit faster."

JerkinOfGrease.components = {
  components.Item(),
  components.Equipment{
    slot = "body",
    effects = {
      conditions.Modifystats{
        AC = 2
      },
      FreedomOfMovement()
    }
  },
  components.Cost{rarity = "uncommon"}
}

return JerkinOfGrease
