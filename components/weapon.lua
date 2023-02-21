local Component = require "component"
local Condition = require "condition"

local Weapon = Component:extend()
Weapon.name = "Weapon"

Weapon.requirements = {components.Item}

function Weapon:__new(options)
  self.stat = options.stat
  self.dice = options.dice
  self.time = options.time or 100
  self.bonus = options.bonus or 0
  self.effects = options.effects or {}
end

function Weapon:initialize(actor)
  actor.stat = self.stat
  actor.dice = self.dice
  actor.time = self.time
  actor.bonus = self.bonus
  actor.effects = self.effects

  local item_component = actor:getComponent(components.Item)
  if item_component then
    item_component.stackable = false
  end
  
  actor:applyCondition(conditions.Wield())
end

return Weapon
