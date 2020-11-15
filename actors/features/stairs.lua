local Actor = require "actor"
local Action = require "action"
local Tiles = require "tiles"

local targetStair = targets.Actor:extend()

function targetStair:validate(owner, actor)
  return actor:is(actors.Stairs)
end

local Exit = Action:extend()
Exit.name = "descend"
Exit.targets = {targetStair}

function Exit:perform(level)
  level.exit = true
end

local Stairs = Actor:extend()

Stairs.char = Tiles["stairs"]
Stairs.name = "stairs"
Stairs.passable = false

Stairs.components = {
  components.Usable({Exit}, Exit),
}

return Stairs
