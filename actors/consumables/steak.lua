local Actor = require "actor"
local Tiles = require "tiles"

local Steak = Actor:extend()
Steak.name = "Steak"
Steak.description = "A juicy and mysterious steak."
Steak.color = {0.97, 0.33, 0.35, 1}
Steak.char = Tiles["steak"]

Steak.components = {
  components.Item{ stackable = true },
  components.Usable(),
  components.Edible{ nutrition = 10 },
  components.Cost{rarity = "rare"}
}

return Steak
