local Component = require "component"

local Drinkable = Component:extend()
Drinkable.name = "Drinkable"

Drinkable.requirements = {
  components.Item,
  components.Usable,
 }

 function Drinkable:__new(options)
   assert(options.drink:is(actions.Drink))
   self._drink = options.drink
 end

function Drinkable:initialize(actor)
  actor:addUseAction(self._drink)
end

return Drinkable
