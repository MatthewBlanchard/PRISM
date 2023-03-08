local System = require "system"

--- This System handles an edge case around equipment and inventory. It checks to see if an actor has moved
--- while still being equipped, and if so, forces an unequip action to prevent cases where an actor is moved
--- but the equipment is not unequipped.
-- @type EquipmentSystem
local EquipmentSystem = System:extend()
EquipmentSystem.name = "Equipment"

--- Performs a sanity check to ensure that the given actor has an Equipment component, and if so,
--- forces an unequip action to prevent cases where an actor is moved but the equipment is not unequipped.
-- @tparam Level level The level the actor is in
-- @tparam Actor actor The actor to check for equipment
function EquipmentSystem:onMove(level, actor)
    -- is the moved actor a piece of equipment?
    local equipment_component = actor:getComponent(components.Equipment)
    if not equipment_component then return end

    -- is the equipment being worn?
    local equipper = equipment_component.equipper
    if not equipper then return end

    -- does the equipper still have an equipper component?
    local equipper_component = equipment_component.equipper:getComponent(components.Equipper)
    if not equipper_component then return end
    
    -- is the equipment still in the slot it was in?
    if equipper_component and equipper_component.slots[equipment_component.slot] == actor then
        print(actor.name)
        local unequip = equipper:getAction(actions.Unequip)(equipper, {actor})
        -- we found a piece of equipment that's gotten loose from the slot time to
        -- unequip it
        
        -- this is marked as a free action so that it doesn't count against the actor's
        -- initiative
        level:performAction(unequip, true)
    end

    equipment_component.equipper = nil
end

function EquipmentSystem:registerLights(level)
    local lights = {}

    for actor in level:eachActor(components.Equipper) do
        local equipper_component = actor:getComponent(components.Equipper)
        for slot, equipment in pairs(equipper_component.slots) do
            if equipment then
                local light_component = equipment:getComponent(components.Light)
                if light_component then
                    table.insert(lights, {actor.position.x, actor.position.y, light_component})
                end
            end
        end
    end

    return lights
end

return EquipmentSystem