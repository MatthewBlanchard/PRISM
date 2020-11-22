local Actor = require "actor"
local Tiles = require "tiles"

local CloakOfInvisibility = Actor:extend()
CloakOfInvisibility.char = Tiles["cloak"]
CloakOfInvisibility.name = "Cloak of Invisibility"
CloakOfInvisibility.description= "The inside of the cloak swirls in unfathomable patterns. You are invisible while wearing it."

CloakOfInvisibility.components = {
  components.Item(),
  components.Equipment{
    slot = "body",
    effects = {
      conditions.Modifystats{
        MGK = 1,
        MR = 1,
        AC = 1
      },
      conditions.Invisibility()
    }
  },
  components.Cost{rarity = "mythic"}
}

return CloakOfInvisibility
