local Component = require "component"

local Attacker = Component:extend()
Attacker.name = "Attacker"

Attacker.requirements = {
  components.Stats
}

Attacker.actions = {
  actions.Attack,
  actions.Wield,
  actions.Unwield
}

function Attacker:__new(options)
  self.defaultAttack = options.defaultAttack
  self.wielded = self.defaultAttack
end

return Attacker
