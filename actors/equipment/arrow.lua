local Actor = require "actor"
local Action = require "action"
local Tiles = require "tiles"

local Arrow = Actor:extend()
Arrow.name = "arrow"
Arrow.char = Tiles["arrow"]
Arrow.color = {0.8, 0.5, 0.1, 1}

Arrow.components = {
  components.Item({stackable = true})
}

return Arrow