local Action = require "action"

local LevelUp = Action:extend()
LevelUp.time = 100

function LevelUp:__new(owner, stat, skill)
  Action.__new(self, owner)
  self.skill = skill
  self.stat = stat
end

function LevelUp:perform(level)
  local actor = self.owner
  actor[self.stat] = actor[self.stat] + 1
  actor.level = actor.level + 1
  if self.skill then
  end
end

return LevelUp