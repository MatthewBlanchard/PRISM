local Condition = require "condition"

local ChemicalCuriosity = Condition:extend()
ChemicalCuriosity.name = "Chemical Curiosity"
ChemicalCuriosity.description = "When you drink a potion each of your wands gains a charge."

ChemicalCuriosity:onAction(actions.Drink,
  function(self, level, actor, action)
    for k, v in pairs(actor.inventory) do
      if v:hasComponent(components.Wand) then
        v:modifyCharges(1)
      end
    end
  end
)

return ChemicalCuriosity
