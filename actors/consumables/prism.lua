local Actor = require "actor"
local Action = require "action"
local Tiles = require "tiles"
local LevelUpPanel = require "panels.level_up"

local LevelUp = Action:extend()
LevelUp.name = "consume"
LevelUp.targets = {targets.Item}

function LevelUp:perform(level)
  local target = self.targetActors[1]
  level:destroyActor(target)
  self.owner:setHP(self.owner:getHP() + 5)
  game.interface:push(LevelUpPanel(game.interface.display, game.interface))
end

local Prism = Actor:extend()
Prism.name = "Prism of Enlightenment"
Prism.color = {0.67, 0.78, 0.9, 1}
Prism.emissive = true
Prism.char = Tiles["prism"]
Prism.lightEffect = components.Light.effects.pulse({ 0.5, 0.5, 0.5, 1 }, 0.2, .2)

Prism.components = {
  components.Light({ 0.0, 0.0, 0.0, 1}, 3, Prism.lightEffect),
  components.Item(),
  components.Usable{LevelUp}
}

return Prism