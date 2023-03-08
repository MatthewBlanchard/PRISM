local Component = require "component"
local Condition = require "condition"

local Equipment = Component:extend()
Equipment.name = "Equipment"

Equipment.requirements = {components.Item}

function Equipment:__new(options)
  self.slot = options.slot
  self.effects = options.effects or {}
end

function Equipment:initialize(actor)
  local item_component = actor:getComponent(components.Item)
  if item_component then
    item_component.stackable = false
  end
end

return Equipment
