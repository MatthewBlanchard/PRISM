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

function lootUtil.generateLoot(comp, rarity)
  print "YEET"
  local found = {}
  local rarity = rarity or "mythic"
  local rarityMod = rarityModifier[rarity]

  for k, actor in pairs(actors) do
    local costComponent = actor:getComponent(components.Cost)
    if
      costComponent and
      rarityModifier[costComponent.rarity] <= rarityMod and
      actor:hasComponent(comp)
    then
      table.insert(found, actor)
    end
  end

  return found[love.math.random(1, #found)]()
end


return lootUtil
