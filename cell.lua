local Object = require "object"
local Tiles = require "tiles"

local Cell = Object:extend()
Cell.name = "Air" -- displayed in the user interface
Cell.tile = Tiles["floor"]
Cell.passable = true -- defines whether a cell is passable
Cell.opaque = false -- defines whether a cell can be seen through
Cell.sightLimit = nil -- if set to an integer an actor standing on this tile's sight range will be limited to this number
Cell.movePenalty = 0 -- applies a penalty to speed when moving through this cell

function Cell:__new()
end

function Cell:onEnter(level, actor) -- called when an actor enters the cell
end

function Cell:onLeave(level, actor) -- called when an actor leaves the cell
end

function Cell:onAction(level, actor, action) -- called when an action is taken on the cell
end

return Cell