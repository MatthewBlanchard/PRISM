local Reaction = require "reaction"

local Die = Reaction:extend()
Die.name = "die"
Die.messageIgnoreTarget = true

function Die:__new(owner, targets, damage)
  Reaction.__new(self, owner, targets)
  self.dealer = targets[1]
  self.damage = damage
end

function Die:perform(level)
  level:destroyActor(self.owner)
end

return Die
