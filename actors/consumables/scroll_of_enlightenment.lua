local Actor = require "actor"
local Action = require "action"
local Tiles = require "tiles"

local Read = Action:extend()
Read.name = "read"
Read.targets = {targets.Item}

function Read:perform(level)
  level:destroyActor(self.targetActors[1])
  for actor in level:eachActor(components.Item) do 
	if actor:is(actors.Prism) then
	  if not self.owner.fov[actor.position.x] then 
		self.owner.fov[actor.position.x] = {}
	  end
	  self.owner.fov[actor.position.x][actor.position.y] = true
	  return
	end
  end
end

local Scroll = Actor:extend()
Scroll.name = "Scroll of Enlightenment"
Scroll.color = {0.8, 0.8, 0.8, 1}
Scroll.char = Tiles["scroll"]

Scroll.components = {
  components.Item(),
  components.Usable{Read}
}

return Scroll