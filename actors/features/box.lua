local Actor = require "actor"
local Tiles = require "tiles"
local Vector2 = require "vector"


local Box = Actor:extend()
Box.name = "box"
Box.speed = 0
Box.char = Tiles["box"]
Box.color = {0.8, 0.5, 0.1, 1}
Box.blocksView = false

Box.components = {
  components.Move{speed = 0, passable = false},
  components.Usable(),
  components.Pushable(),
  components.Stats{
    maxHP = 1,
    AC = 0
  }
}

return Box
