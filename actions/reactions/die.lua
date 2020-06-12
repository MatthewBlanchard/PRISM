local Reaction = require "reaction"

local Die = Reaction:extend()
Die.name = "die"

function Die:__new(owner, damage, dealer)
  Reaction.__new(self, owner, nil)
  self.dealer = dealer
  self.damage = damage
end

function Die:perform(level)
  level:destroyActor(self.owner)
end

return Die
