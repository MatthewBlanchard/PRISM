local Actor = require "actor"
local Tiles = require "tiles"

local Steak = Actor:extend()
Steak.name = "Steak"
Steak.description = "This steak looks like it's been marinated in mystery and seared with intrigue. Eat at your own risk, and prepare for a flavor adventure."
Steak.color = {0.97, 0.33, 0.35, 1}
Steak.char = Tiles["steak"]

Steak.components = {
  components.Item{ stackable = true },
  components.Usable(),
  components.Edible{ nutrition = 10 },
  components.Cost{rarity = "rare"}
}

return Steak
