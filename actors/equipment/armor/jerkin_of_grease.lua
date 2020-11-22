local Actor = require "actor"
local Condition = require "condition"
local Tiles = require "tiles"

local FreedomOfMovement = Condition:extend()
FreedomOfMovement.name = "FreedomOfMovement"
FreedomOfMovement.description= "You have an 90 move speed and can't be reduced."

FreedomOfMovement:setTime(actions.Move,
  function(self, level, actor, action)
    action.time = math.min(action.time, 90)
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
        AC = 2,
        PR = 1
      },
      FreedomOfMovement()
    }
  },
  components.Cost{rarity = "rare"}
}

return JerkinOfGrease
