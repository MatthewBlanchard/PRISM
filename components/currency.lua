local Component = require "component"

local Currency = Component:extend()
Currency.name = "Currency"

function Currency:__new(options)
  self.worth = options and options.worth or 1
end

return Currency
