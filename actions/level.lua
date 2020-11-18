local Action = require "action"

local LevelUp = Action:extend()
LevelUp.time = 0

function LevelUp:__new(owner, feat)
  Action.__new(self, owner)
  self.feat = feat
end

function LevelUp:perform(level)
  local actor = self.owner

  actor:applyCondition(self.feat())
end

return LevelUp
