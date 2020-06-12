local Component = require "component"
local Condition = require "condition"

local Weapon = Component:extend()

Weapon.requirements = {components.Item}

function Weapon:__new(options)
  self.name = options.name
  self.stat = options.stat
  self.dice = options.dice
  self.effects = options.effects or {}
end

function Weapon:initialize(actor)
  actor.name = self.name
  actor.stat = self.stat
  actor.dice = self.dice
  actor.effects = self.effects
  actor:applyCondition(conditions.Wield())
end

return Weapon
