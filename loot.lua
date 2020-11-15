local componentCost = {
  [components.Weapon] = 10,
  [components.Wand] = 12,
  [components.Edible] = 3,
  [components.Drinkable] = 5,
  [components.Readable] = 7,
  [components.Equipment] = 15,
}

local rarityModifier = {
  common = 1,
  uncommon = 2,
  rare = 3,
  mythic = 4,
}

local lootUtil = {}

function lootUtil.generateBasePrice(actor)
  local price = 0

  for k, v in pairs(componentCost) do
    if actor:hasComponent(k, "loot") then
      price = price + v
    end
  end

  print(actor.name, price * rarityModifier[actor.rarity])
  return price * rarityModifier[actor.rarity]
end

return lootUtil
