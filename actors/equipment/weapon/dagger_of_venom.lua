local Actor = require "actor"
local Tiles = require "tiles"

local poisonOnHit = conditions.Onhit:extend()

function poisonOnHit:onHit(level, attacker, defender)
  defender:applyCondition(conditions.Poisoned)
end

local Dagger_of_Venom = Actor:extend()
Dagger_of_Venom.char = Tiles["dagger"]
Dagger_of_Venom.name = "Dagger of Venom"
Dagger_of_Venom.description= "Inflicts a dangerous poison on your enemies!"
Dagger_of_Venom.color = {0.1, 1, 0.1}

Dagger_of_Venom.components = {
  components.Item(),
  components.Weapon{
    stat = "ATK",
    name = "Dagger of Venom",
    dice = "1d4",
    bonus = 1,
    time = 75,
    effects = {
      poisonOnHit
    }
  },
  components.Cost{rarity = "uncommon"}
}

return Dagger_of_Venom
