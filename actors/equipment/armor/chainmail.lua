local Actor = require "actor"
local Tiles = require "tiles"

local Chainmail = Actor:extend()
Chainmail.char = Tiles["armor"]
Chainmail.name = "Chainmail"

Chainmail.components = {
  components.Item(),
  components.Equipment{
    slot = "body",
    effects = {
      conditions.Modifystats{
        AC = 3
      }
    }
  }
}

return Chainmail
