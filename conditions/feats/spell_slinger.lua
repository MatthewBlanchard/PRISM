local Condition = require "condition"

local ChemicalCuriosity = Condition:extend()
ChemicalCuriosity.name = "Spell Slinger"
ChemicalCuriosity.description = "You zap faster and your zap attacks are more likely to hit!"

ChemicalCuriosity:onAction(actions.Zap,
  function(self, level, actor, action)
    action.time = action.time - 25
  end
)

ChemicalCuriosity:onAction(actions.Attack,
  function(self, level, actor, action)
    if action.weapon.stat ~= "MGK" then return end

    action.attackBonus = action.attackBonus + 2
  end
)

return ChemicalCuriosity
