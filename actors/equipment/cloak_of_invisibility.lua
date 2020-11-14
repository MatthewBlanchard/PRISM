local Actor = require "actor"
local Tiles = require "tiles"

local CloakOfInvisibility = Actor:extend()
CloakOfInvisibility.char = Tiles["cloak"]
CloakOfInvisibility.name = "Cloak of Invisibility"
CloakOfInvisibility.desc = "The inside of the cloak swirls in unfathomable patterns."

CloakOfInvisibility.components = {
  components.Item(),
  components.Equipment{
    slot = "body",
    effects = {
      conditions.Modifystats{
        AC = 2
      },
      conditions.Invisibility()
    }
  }
}

return CloakOfInvisibility
