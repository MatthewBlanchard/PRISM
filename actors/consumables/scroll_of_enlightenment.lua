local Actor = require "actor"
local Action = require "action"
local Tiles = require "tiles"
local Condition = require "condition"

local Scrying = Condition:extend()
Scrying.name = "Scrying"
Scrying.damage = 1

Scrying:onScry(
  function(self, level, actor)
    return { level:getActorByType(actors.Prism) }
  end
)

local Read = actions.Read:extend()
Read.name = "read"
Read.targets = {targets.Item}

function Read:perform(level)
  actions.Read.perform(self, level)
  self.owner:applyCondition(Scrying())
end

local Scroll = Actor:extend()
Scroll.name = "Scroll of Enlightenment"
Scroll.color = {0.8, 0.8, 0.8, 1}
Scroll.char = Tiles["scroll"]

Scroll.components = {
  components.Item(),
  components.Usable(),
  components.Readable{read = Read},
  components.Cost()
}

return Scroll
