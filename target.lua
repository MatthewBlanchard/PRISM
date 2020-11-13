local Object = require "object"

local targets = {}

local Target = Object:extend()
Target.range = 0
targets.Target = Target

function Target:extend()
  local self = Object.extend(self)

  if self.requirements then

    local comp = {}
    for k, v in pairs(self.requirements) do
      table.insert(comp, v)
    end
    self.requirements = comp
  else
    self.requirements = {}
  end

  return self
end

function Target:__new(range)
  self.range = range or self.range
  self.canTargetSelf = false
end

function Target:addRequirement(component)
  table.insert(self.requirements, component)
end

function Target:setRange(range, enum)
  self.range = range
  self.rtype = enum
end

function Target:validate(owner, toValidate)

end

function Target:checkRequirements(actor)

end

local ActorTarget = Target:extend()

function ActorTarget:__new(range)
  Target.__new(self, range)
  self.canTargetSelf = false
end

function ActorTarget:validate(owner, actor)
  local range = false

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

function ActorTarget:checkRequirements(actor)
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

local PointTarget = Target:extend()

function PointTarget:validate(owner, vec2)
  if not vec2.x and vec2.y then return false end

  return owner:getRange(self.rtype, vec2)
end

function PointTarget:checkRequirements(vec2)
  return vec2.x and vec2.y
end

targets.Actor = ActorTarget
targets.Point = PointTarget

targets.Creature = targets.Actor:extend()
targets.Creature.requirements = {components.Stats}

targets.Living = targets.Actor:extend()
targets.Living.requirements = {components.Stats, components.Aicontroller}

targets.Item = targets.Actor:extend()
targets.Item.name = "item"
targets.Item.requirements = {components.Item}

targets.Equipment = targets.Item:extend()
targets.Equipment:addRequirement(components.Equipment)

function targets.Equipment:validate(owner, actor)
  return targets.Item.validate(self, owner, actor) and owner:hasSlot(actor.slot) and not owner.slots[actor.slot]
end

targets.Weapon = targets.Item:extend()
targets.Weapon:addRequirement(components.Weapon)

function targets.Weapon:validate(owner, actor)
  return targets.Item.validate(self, owner, actor) and owner:hasComponent(components.Attacker) and not (owner.wielded == actor)
end

targets.Unequip = targets.Item:extend()
targets.Unequip:addRequirement(components.Equipment)

function targets.Unequip:validate(owner, actor)
  return targets.Item.validate(self, owner, actor) and owner.slots[actor.slot] == actor
end

targets.Unwield = targets.Item:extend()
targets.Unwield:addRequirement(components.Weapon)

function targets.Unwield:validate(owner, actor)
  return targets.Item.validate(self, owner, actor) and owner.wielded == actor
end

return targets
