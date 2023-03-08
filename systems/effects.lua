local System = require "system"

--- The Effects system handles messaging the interface about events. This is sort of a kludge.
-- @type Effects
local Effects = System:extend()
Effects.name = "Effects"

function Effects:__new()
    self.effects = {}
end

function Effects:afterAction(level, actor, action)
    if self.effectAfterAction then
        self:addEffect(self.effectAfterAction)
        self.effectAfterAction = nil
    end
end
  
function Effects:addEffect(effect)
    -- we push the effect onto the effects stack and then the interface
    -- resolves these
    table.insert(self.effects, effect)

    if self.suppressEffect then return end
    coroutine.yield("effect")
end


function Effects:addEffectAfterAction(effect)
    self.effectAfterAction = effect
end

-- these functions are used to suppress effects from being sent to the interface
-- a good example of this is a fireball where we want all the damage effects to
-- play at the same time 
function Effects:suppressEffects()
    self.suppressEffect = true
end

-- Once this is called all of the effects that have been suppressed will be sent
-- to the interface
function Effects:resumeEffects()
    self.suppressEffect = false
    coroutine.yield("effect")
end

return Effects