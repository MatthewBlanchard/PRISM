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
  door.char = Tiles["door_open"]
  door.passable = true
  door.blocksVision = false
  game.level:invalidateLighting()
end

local Door = Actor:extend()

Door.char = Tiles["door_closed"]
Door.name = "door"
Door.passable = false
Door.blocksVision = true

Door.components = {
  components.Usable({Open}, Open),
}

return Door
