local Actor = require "actor"
local Action = require "action"

local targetDoor = targets.Target()

function targetDoor:validate(owner, actor)
  return actor:is(actors.Door)
end

local Open = Action:extend()
Open.name = "open"
Open.targets = {targetDoor}

function Open:perform(level)
  local door = self.targetActors[1]
  door.char = "-"
  door.passable = true
  door.blocksVision = false
  game.level:invalidateLighting()
end

local Door = Actor:extend()

Door.char = "+"
Door.name = "door"
Door.passable = false
Door.blocksVision = true

Door.components = {
  components.Usable({Open}, Open),
  components.Stats
  {
    STR = 0,
    DEX = 0,
    INT = 0,
    CON = 0,
    maxHP = 10,
    AC = 10
  },
}

return Door
