local Action = require "action"

local LevelUp = Action:extend()
LevelUp.time = 100

function LevelUp:__new(owner, feat)
  Action.__new(self, owner)
  self.feat = feat
end

function LevelUp:perform(level)
  local actor = self.owner

  if self.feat then
    actor:applyCondition(self.feat)
  end
end

return LevelUp