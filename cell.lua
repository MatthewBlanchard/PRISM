local Object = require "object"
local Tiles = require "tiles"

local Cell = Object:extend()
Cell.name = "Air" -- displayed in the user interface
Cell.tile = Tiles["floor"]
Cell.passable = true -- defines whether a cell is passable
Cell.opaque = false -- defines whether a cell can be seen through
Cell.movePenalty = 0

function Cell:__new()
end

function Cell:onEnter(level, actor) -- called when an actor enters the cell
end

function Cell:onLeave(level, actor) -- called when an actor leaves the cell
end

function Cell:onAction(level, actor, action) -- called when an action is taken on the cell
end

return Cell