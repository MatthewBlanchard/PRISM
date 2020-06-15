local Actor = require "actor"
local Tiles = require "tiles"

local Dagger_of_Venom = Actor:extend()
Dagger_of_Venom.char = Tiles["dagger"]
Dagger_of_Venom.name = "Dagger of Venom"
Dagger_of_Venom.color = {0.1, 1, 0.1}

Dagger_of_Venom.components = {
  components.Item(),
  components.Weapon{
    stat = "DEX",
    name = "Dagger of Venom",
    dice = "1d4+1",
    bonus = 1,
    time = 75,
    effects = {
      conditions.Onhit(
        conditions.Poisoned(1, 1000),
        1 -- chance to apply effect
      )
    }
  }
}

return Dagger_of_Venom
