local Object = require "object"
local Vector2 = require "vector"

local targets = {}

local Target = Object:extend()
Target.range = 0
targets.Target = Target

function Target:extend()
  local self = Object.extend(self)

  return self
end

function Target:__new(range)
  self.range = range or self.range
  self.canTargetSelf = false
end

function Target:setRange(range, enum)
  self.range = range
  self.rtype = enum
end

function Target:validate(owner, toValidate)
end

local ActorTarget = Target:extend()
ActorTarget.rtype = "box"

function ActorTarget:__new(range)
  Target.__new(self, range)
  self.canTargetSelf = false
end

function ActorTarget:validate(owner, actor)
  local range = false

  if owner == actor and not self.canTargetSelf then return false end

  if self.range == 0 then
    local inventory = owner:getComponent(components.Inventory)
    if inventory and inventory:hasItem(actor) then
      range = true
    end

    if owner.position == actor.position then
      range = true
    end
  else
    range = owner:getRange(self.rtype, actor) <= self.range
  end

  return range
end

local PointTarget = Target:extend()

function PointTarget:validate(owner, vec2)
  return owner:getRange(self.rtype, vec2)
end

function PointTarget:checkRequirements(vec2)
  return vec2.x and vec2.y
end

targets.Actor = ActorTarget
targets.Point = PointTarget

targets.Creature = targets.Actor:extend()

function targets.Creature:validate(owner, actor)
  return ActorTarget.validate(self, owner, actor) and actor:hasComponent(components.Stats)
end

targets.Living = targets.Actor:extend()

function targets.Living:validate(owner, actor)
  return targets.Actor.validate(self, owner, actor) 
    and actor:hasComponent(components.Stats)
    and actor:hasComponent(components.Controller)
end

targets.Item = targets.Actor:extend()
targets.Item.requirements = {components.Item}

function targets.Item:validate(owner, actor)
  return targets.Actor.validate(self, owner, actor) and actor:hasComponent(components.Item)
end

targets.Equipment = targets.Item:extend()

function targets.Equipment:validate(owner, actor)
  local equipper = owner:getComponent(components.Equipper)
  local equipment = actor:getComponent(components.Equipment)
  local hasSlot = equipment and equipper and equipper:hasSlot(equipment.slot) or false
  local slotEmpty = equipment and equipper and equipper:getSlot(equipment.slot) == false 

  return targets.Item.validate(self, owner, actor) and hasSlot and slotEmpty
end

targets.Weapon = targets.Item:extend()

function targets.Weapon:validate(owner, actor)
  local weapon_component = actor:getComponent(components.Weapon)
  local attacker_component = owner:getComponent(components.Attacker)

  local wielded = attacker_component and attacker_component.wielded == actor or false
  return targets.Item.validate(self, owner, actor) and weapon_component and not wielded
end

targets.Unequip = targets.Item:extend()
targets.Unequip.range = math.huge -- Target is bounded by being equipped so we can set range to infinite

function targets.Unequip:validate(owner, actor)
  local equipper = owner:getComponent(components.Equipper)
  local equipment = actor:getComponent(components.Equipment)
  
  local isEquipped = equipment and equipper and equipper.slots[equipment.slot] == actor
  return targets.Item.validate(self, owner, actor) and isEquipped
end

targets.Unwield = targets.Item:extend()

function targets.Unwield:validate(owner, actor)
  local weapon_component = actor:getComponent(components.Weapon)
  local attacker = owner:getComponent(components.Attacker)

  local wielded = attacker and attacker.wielded == actor or false
  return targets.Item.validate(self, owner, actor) and weapon_component and wielded
end

return targets
