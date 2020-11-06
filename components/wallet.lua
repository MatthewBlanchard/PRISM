local Component = require "component"

local Wallet = Component:extend()

function Wallet:__new()
  self.wallet = {}
end

function Wallet:initialize(actor)
  actor.wallet = self.wallet
  actor.deposit = self.deposit
  actor.withdraw = self.withdraw
  actor.hasAmount = self.hasAmount
end

function Wallet:deposit(owner, currency)
  local meta = getmetatable(currency)
  if not owner.wallet[meta] then 
    owner.wallet[meta] = 0
  end
  owner.wallet[meta] = owner.wallet[meta] + currency.worth
end

function Wallet:hasAmount(owner, currency)
  local meta = getmetatable(currency)

  if not owner.wallet[meta] then 
    return nil 
  end
  return owner.wallet[meta] >= currency.worth
end

function Wallet:withdraw(owner, currency)
  local meta = getmetatable(currency)

  if not owner.wallet[meta] then 
    return nil 
  end

  if owner.wallet[meta] >= currency.worth then 
    owner.wallet[meta] = owner.wallet[meta] - currency.worth
    return true
  else 
    return nil
  end
end

return Wallet
