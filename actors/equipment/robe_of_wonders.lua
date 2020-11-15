local Actor = require "actor"
local Tiles = require "tiles"

local RobeOfWonders = Actor:extend()
RobeOfWonders.char = Tiles["cloak"]
RobeOfWonders.name = "Robe of Wonders"
RobeOfWonders.description= "This robe feels weightless. It's made of thin shiny cloth."

RobeOfWonders.components = {
  components.Item(),
  components.Equipment{
    slot = "body",
    effects = {
      conditions.Modifystats{
        AC = 1
      },
      conditions.Refundcharge{
        chance = 0.5
      }
    }
  }
}

return RobeOfWonders
