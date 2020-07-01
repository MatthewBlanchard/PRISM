local Component = require "component"

local Wallet = Component:extend()

function Wallet:__new()
  self.wallet = {}
end

function Wallet:initialize(actor)
  actor.wallet = self.wallet
  actor.deposit = self.deposit
end

function Wallet:deposit(owner, currency)
  local meta = getmetatable(currency)
  if not owner.wallet[meta] then 
    owner.wallet[meta] = 0
  end
  owner.wallet[meta] = owner.wallet[meta] + currency.worth
end


return Wallet
