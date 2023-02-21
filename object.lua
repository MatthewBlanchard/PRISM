local Object = {}

function Object:extend()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  self.__call = self.__call or Object.__call

  return o
end

-- Metamethods
function Object:__call(...)
  local o = {}
  setmetatable(o, self)
  self.__index = self

  o:__new(...)
  return o
end

-- Constructor
function Object:__new()
end

-- Checks if self is a child of o. It will follow
-- the inheritance chain to check if self is a child
-- of o.
function Object:is(o)
  if self == o then return true end

  local parent = getmetatable(self)
  while parent do
    if parent == o then
      return true
    end

    parent = getmetatable(parent)
  end

  return false
end

-- Same functionality as is except it will only check
-- the immediate parent of self.
function Object:extends(o)
  if self == o then return true end

  if getmetatable(self) == o then
    return true
  end

  return false
end

return Object:__call()
