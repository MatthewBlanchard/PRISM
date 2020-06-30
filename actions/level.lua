local Action = require "action"

local LevelUp = Action:extend()
LevelUp.time = 100

function LevelUp:__new(owner, stat, feat)
  Action.__new(self, owner)
  self.stat = stat
  self.feat = feat
end

function LevelUp:perform(level)
  local actor = self.owner
  actor[self.stat] = actor[self.stat] + 1
  actor.levels[self.stat] = actor.levels[self.stat] + 1

  if self.feat then
    actor:applyCondition(self.feat)
  end
end

return LevelUp