local Actor = require "actor"
local Action = require "action"
local Tiles = require "tiles"
local Vector2 = require "vector"

local targetBox = targets.Actor:extend()

function targetBox:validate(owner, actor)
  return actor:is(actors.Box)
end

local Push = Action:extend()
Push.name = "push"
Push.targets = {targetBox}
Push.silent = true

function Push:perform(level)
  local box = self.targetActors[1]
  local movement = box.position - self.owner.position
  if movement.y == 0 or movement.x == 0 then
	level:performAction(box:getAction(actions.Move)(box, movement))
	level:performAction(self.owner:getAction(actions.Move)(self.owner, movement))
  end
end

local Box = Actor:extend()
Box.name = "box"
Box.speed = 0
Box.char = Tiles["box"]
Box.color = {0.8, 0.5, 0.1, 1}
Box.passable = false
Box.blocksView = false

function Box:act(level)
  return self:getAction(actions.Move)(self, Vector2(0, 0))
end

Box.components = {
  components.Usable({Push}, Push),
  components.Move(),
  components.Aicontroller()
}

return Box