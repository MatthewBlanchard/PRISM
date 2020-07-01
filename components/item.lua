local Component = require "component"

local Item = Component:extend()

function Item:__new(options)
  self.stackable = options and options.stackable or false
end

function Item:initialize(actor)
  actor.stackable = self.stackable
end

return Item
