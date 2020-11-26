local Condition = require "condition"

local OnAttack = Condition:extend()
OnAttack.name = "OnAttack"

function OnAttack:onAttack(level, attacker, defender, action)
  print("hey")
end

OnAttack:afterAction(actions.Attack,
  function(self, level, actor, action)
    local defender = action:getTarget(1)
    if defender ~= actor then
      self:onAttack(level, actor, defender, action)
    end
  end
)

return OnAttack 