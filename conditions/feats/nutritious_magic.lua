local Condition = require "condition"

local NitritiousMagic = Condition:extend()
NitritiousMagic.name = "Flavor Mage"
NitritiousMagic.description = "Every time you zap a wand you gain life equal to your MGK stat. Yum."

NitritiousMagic:afterAction(actions.Zap,
  function(self, level, actor, action)
    local eater = action.owner
    local food = action:getTarget(1)
    local heal = eater:getReaction(reactions.Heal)
    level:performAction(heal(eater, {eater}, eater:getStatBonus("MGK")))
  end
)

return NitritiousMagic
