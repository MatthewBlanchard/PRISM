local Actor = require "actor"
local Action = require "action"
local Tiles = require "tiles"

local targetDoor = targets.Target()

function targetDoor:validate(owner, actor)
  return actor:is(actors.Chest)
end

local Open = Action:extend()
Open.name = "open"
Open.targets = {targetDoor}

function Open:perform(level)
  local chest = self.targetActors[1]
  level:destroyActor(chest)

  local item = chest.inventory[1]
  item.position.x = chest.position.x
  item.position.y = chest.position.y
  level:addActor(item)
  level:addEffect(effects.OpenEffect(chest))
end

local Chest = Actor:extend()
Chest.char = Tiles["chest"]
Chest.color = {0.8, 0.8, 0.1, 1}
Chest.name = "chest"
Chest.passable = false
Chest.blocksView = false

Chest.components = {
  components.Usable({Open}, Open),
  components.Inventory()
}

return Chest
