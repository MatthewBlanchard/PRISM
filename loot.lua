local Weapon = require "components.weapon"
local Wand = require "components.wand"
local Edible = require "components.edible"
local Drinkable = require "components.drinkable"
local Equipment = require "components.equipment"

local componentCost = {
  [Weapon] = 10,
  [Wand] = 12,
  [Edible] = 3,
  [Drinkable] = 5,
  [Equipment] = 15,
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
  print(actor.rarity)

  for k, v in pairs(componentCost) do
    if actor:is(k) then
      price = price + v
    end
  end

  print "YA"
  print(actor.name, price * rarityModifier[actor.rarity])
  return price * rarityModifier[actor.rarity]
end

return lootUtil
