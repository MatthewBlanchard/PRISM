local Component = require "component"

local Usable = Component:extend()

function Usable:__new(actions, default)
  self.useActions = actions
  self.defaultUseAction = default or self.useActions[1]
end

function Usable:initialize(actor)
  actor.useActions = self.useActions
  actor.defaultUseAction = self.defaultUseAction
end

return Usable
