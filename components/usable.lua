local Component = require "component"

local Usable = Component:extend()
Usable.name = "Usable"

function Usable:__new(actions, default)
  self.useActions = actions or {}
  self.defaultUseAction = default
end

function Usable:initialize(actor)
  actor.useActions = {}

  for _, action in ipairs(self.useActions) do
    table.insert(actor.useActions, action)
  end

  actor.defaultUseAction = self.defaultUseAction
  actor.addUseAction = self.addUseAction
  actor.removeUseAction = self.removeUseAction
  actor.getUseAction = self.getUseAction
end

function Usable:getUseAction(action)
  for k, v in pairs(self.useActions) do
    if v:is(action) then
      return v
    end
  end
end

function Usable:addUseAction(action)
  assert(not self:getUseAction(action))
  table.insert(self.useActions, action)
  if not self.defaultUseAction then
    self.defaultUseAction = action
  end
end

function Usable:removeUseAction(action)
  for k, v in pairs(self.useActions) do
    if v:is(action) then
      table.remove(self.useActions, k)
      if self.defaultUseAction == v then
        self.defaultUseAction = nil
      end
      return
    end
  end
end

return Usable
