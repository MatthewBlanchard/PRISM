local System = require "System"

local Hunger = System:extend()
Hunger.name = "Message"

function Hunger:onTick(level, actor, action)
    for actor in level:eachActor() do
        local hunger_component = actor:getComponent(components.Hunger)
        if hunger_component then
            hunger_component.satiation = hunger_component.satiation - 1
        end
    end
end

return Hunger