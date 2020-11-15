local Component = require "component"
local Condition = require "condition"

local Equipment = Component:extend()
Equipment.name = "Equipment"

Equipment.requirements = {components.Item}

function Equipment:__new(options)
  self.slot = options.slot
  self.effects = options.effects
end

function Equipment:initialize(actor)
  actor.slot = self.slot
  actor.effects = self.effects
  actor.stackable = false
  actor:applyCondition(conditions.Equip())
end

return Equipment
