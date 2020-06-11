local Actor = require "actor"
local Tiles = require "tiles"

local CloakOfInvisibility = Actor:extend()
CloakOfInvisibility.char = Tiles["armor"]
CloakOfInvisibility.name = "Cloak of Invisibility"

CloakOfInvisibility.components = {
  components.Item(),
  components.Equipment{
    slot = "cloak",
    effects = {
      conditions.Invisibility()
    }
  }
}

return CloakOfInvisibility
