local Component = require "component"

local Item = Component:extend()
Item.name = "Item"

function Item:__new(options)
  self.stackable = options and options.stackable or false
end

return Item
