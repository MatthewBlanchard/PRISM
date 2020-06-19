local Object = require "object"

local targets = {}

local Target = Object:extend()
targets.Target = Target

function Target:__new(range)
  if self.requirements then

    local comp = {}
    for k, v in pairs(self.requirements) do
      table.insert(comp, v)
    end
    self.requirements = comp
  else
    self.requirements = {}
  end

  self.range = 0 or range
  self.canTargetSelf = false
end

function Target:addRequirement(component)
  table.insert(self.requirements, component)
end

function Target:setRange(range, enum)
  self.range = range
  self.rtype = enum
end

function Target:validate(owner, actor)
  local range

  if owner == actor and not self.canTargetSelf then return false end

  if self.range == 0 then
    if owner:hasComponent(components.Inventory) then
      for k, v in pairs(owner.inventory) do
        if v == actor then
          range = true
        end
      end
    end

    if owner.position == actor.position then
      range = true
    end
  else
    range = owner:getRange(self.rtype, actor) <= self.range
  end

  return self:checkRequirements(actor) and range
end

function Target:checkRequirements(actor)
  local foundreqs = {}

  for k, component in pairs(actor.components) do
    for k, req in pairs(self.requirements) do
      if component:is(req) then
        table.insert(foundreqs, component)
      end
    end
  end

  if #foundreqs == #self.requirements then
    return true
  end

  return false
end

targets.Creature = Target()
targets.Creature.requirements = {components.Stats}

targets.Item = Target()
targets.Item.name = "item"
targets.Item.requirements = {components.Item}

targets.Equipment = targets.Item()
targets.Equipment:addRequirement(components.Equipment)

function targets.Equipment:validate(owner, actor)
  return Target.validate(self, owner, actor) and owner:hasSlot(actor.slot) and not owner.slots[actor.slot]
end

targets.Weapon = targets.Item()
targets.Weapon:addRequirement(components.Weapon)

function targets.Weapon:validate(owner, actor)
  return Target.validate(self, owner, actor) and owner:hasComponent(components.Attacker) and not (owner.wielded == actor)
end

targets.Unequip = targets.Item()
targets.Unequip:addRequirement(components.Equipment)

function targets.Unequip:validate(owner, actor)
  return Target.validate(self, owner, actor) and owner.slots[actor.slot] == actor
end

targets.Unwield = targets.Item()
targets.Unwield:addRequirement(components.Weapon)

function targets.Unwield:validate(owner, actor)
  return Target.validate(self, owner, actor) and owner.wielded == actor
end

targets.Position = Target()

return targets
