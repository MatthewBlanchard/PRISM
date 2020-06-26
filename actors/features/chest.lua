local Actor = require "actor"
local Action = require "action"
local Tiles = require "tiles"

local targetDoor = targets.Actor:extend()

function targetDoor:validate(owner, actor)
  return actor:is(actors.Chest)
end

local Open = Action:extend()
Open.name = "open"
Open.targets = {targetDoor}
Open.silent = true

function Open:perform(level)
  local chest = self.targetActors[1]

  if chest.key then
    if chest:hasKey(self.owner) then
      level:destroyActor(chest.key)
    else
      level:addMessage("The chest is locked!", self.owner)
      return nil
    end
  end

  level:destroyActor(chest)

  local message = "You open the chest"
  if chest.key then
    message = "You unlock the chest"
  end

  local item = chest.inventory[1]
  if item then
    item.position.x = chest.position.x
    item.position.y = chest.position.y
    level:addActor(item)
    -- TODO: Make sure the name is formatted correctly
    message = message .. " and find a " .. item.name .. "!"
  else
    message = message .. "."
  end

  level:addMessage(message, self.owner)
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
  components.Inventory(),
  components.Lock()
}

return Chest
