local System = require "System"

local Message = System:extend()
Message.name = "Message"

--- Message needs data from the sight system through the sight components to determine who can see the message
--- In the future Message will likely have softRequirements on Sight/Smell/Hearing if those systems are implemented
--- It will soft require those systems and assert that at least one of them is available.
Message.requirements = { "Sight" }

function Message:afterAction(level, actor, action)
    self:add(level, action)
end

function Message:add(level, message, actor)
    -- if they specified an actor we check if they have a message component and
    -- send them and specifically them that message
    if actor then
        if actor:hasComponent(components.Message) then
            local message_component = actor:getComponent(components.Message)
            message_component:add(message)
            return
        else
            error("Actor specified in Message:add() does not have a Message component.")
        end
    end
  
    -- if actor wasn't specified we send the message to each actor who can see the
    -- message's owner and has a message component
    for actor in level:eachActor(components.Message, components.Sight) do
        local message_component = actor:getComponent(components.Message)
        local sight_component = actor:getComponent(components.Sight)
        if message_component and sight_component then
            for k, v in ipairs(sight_component.seenActors) do
                if v == message.owner then
                    message_component:add(message)
                end
            end
        else
            message_component:add(message)
        end
    end
end

return Message