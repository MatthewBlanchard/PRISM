local Cell = require "cell"
local Tiles = require "tiles"

local Wall = Cell:extend()
Wall.name = "Wall" -- displayed in the user interface
Wall.passable = false -- defines whether a cell is passable
Wall.opaque = true -- defines whether a cell can be seen through
Wall.tile = Tiles["wall"]

return Wall