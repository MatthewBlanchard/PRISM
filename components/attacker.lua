local Component = require "component"

local Attacker = Component:extend()
Attacker.name = "Attacker"
Attacker.requirements = {components.Stats}

function Attacker:__new(options)
  self.defaultAttack = options.defaultAttack
end

function Attacker:initialize(actor)
  actor.defaultAttack = self.defaultAttack
  actor.wielded = self.defaultAttack

  actor:addAction(actions.Attack)
  actor:addAction(actions.Wield)
  actor:addAction(actions.Unwield)
end

return Attacker
