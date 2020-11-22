local Actor = require "actor"
local Tiles = require "tiles"

local meatOnKill = conditions.Onkill:extend()

function meatOnKill:onKill(level, killer, killed)
  if not killed:hasComponent(components.Aicontroller) then return end
  if love.math.random() > 0.66 then
    local steak = actors.Steak()
    steak.position.x, steak.position.y = killed.position.x, killed.position.y
    level:addActor(steak)
  end
end

local CleaverMythical = Actor:extend()
CleaverMythical.char = Tiles["cleaver"]
CleaverMythical.name = "Cleaver of Meats"
CleaverMythical.description= "Reduce your opponents to delicious and mysterious meats!"

CleaverMythical.components = {
  components.Item(),
  components.Weapon{
    stat = "ATK",
    name = "Cleaver of Meats",
    dice = "1d6",
    bonus = 1,
    time = 100,
    effects = {
      meatOnKill
    }
  },
  components.Cost{rarity = "rare"}
}

return CleaverMythical
