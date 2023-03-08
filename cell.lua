local Object = require "object"
local Tiles = require "tiles"

--- A cell is a single tile on the map. It defines the properties of the tile and has a few callbacks.
--- Maybe cells should have components so that they can be extended with custom functionality like the grass?
--- Still working on the details there. For now, cells are just a simple way to define the properties of a tile.
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

--- Cells can have custom functions to determine whether an actor standing on them can be seen.
--- For instance, grass cells allow actors to be seen only if the other actor is in the same 
--- clump of grass.
function Cell:visibleFromCell(level, cell) 
  return true
end

return Cell