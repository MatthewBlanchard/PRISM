local Actor = require "actor"
local Action = require "action"
local Tiles = require "tiles"

local targetDoor = targets.Actor:extend()

function targetDoor:validate(owner, actor)
  return actor:is(actors.Door)
end

local Open = Action:extend()
Open.name = "open"
Open.targets = {targetDoor}

function Open:perform(level)
  local door = self.targetActors[1]
  if door.passable then
    door.char = Tiles["door"]
  else
    door.char = Tiles["door_open"]
  end

  door.passable = not door.passable
  door.blocksVision = not door.passable
  game.level:invalidateLighting()
end

local Door = Actor:extend()

Door.char = Tiles["door_closed"]
Door.name = "door"
Door.passable = false
Door.blocksVision = true

Door.components = {
  components.Usable({Open}, Open),
  components.Stats{
    maxHP = 12,
    AC = 0
  }
}

return Door
