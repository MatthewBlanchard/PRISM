local Actor = require "actor"
local Tiles = require "tiles"

local VenomFang = Actor:extend()
VenomFang.char = Tiles["shortsword"]
VenomFang.name = "Dagger of Venom"
VenomFang.color = {0.1, 1, 0.1}

VenomFang.components = {
  components.Item(),
  components.Weapon{
    stat = "DEX",
    name = "VenomFang",
    dice = "1d4",
    effects = {
      conditions.Onhit(
        conditions.Poisoned(1, 1000),
        1 -- chance to apply effect
      )
    }
  }
}

return VenomFang
