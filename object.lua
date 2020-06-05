local Object = {}

function Object:extend()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  self.__call = Object.__call

  return o
end

-- Metamethods
function Object:__call(...)
    local o = {}
   	setmetatable(o, self)
    self.__index = self
    self.__call = Object.__call

    o:__new(...)
    return o
end

-- Constructor
function Object:__new()
end

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

return Object:__call()
