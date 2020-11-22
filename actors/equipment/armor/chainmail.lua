local Actor = require "actor"
local Tiles = require "tiles"

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
    }
  },
  components.Cost{rarity = "rare"}
}

return JerkinOfGrease
