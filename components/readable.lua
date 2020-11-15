local Component = require "component"

local Readable = Component:extend()
Readable.name = "Readable"

Readable.requirements = {
  components.Item,
  components.Usable,
 }

 function Readable:__new(options)
   assert(options.read:is(actions.Read))
   self._read = options.read
 end

function Readable:initialize(actor)
  actor:addUseAction(self._read)
end

return Readable
