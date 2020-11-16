local Actor = require "actor"
local Action = require "action"
local Tiles = require "tiles"
local FeatsPanel = require "panels.feats"

local Gaze = Action:extend()
Gaze.name = "gaze"
Gaze.targets = {targets.Item}
Gaze.silent = true
Gaze.time = 0

function Gaze:perform(level)
  level:destroyActor(self:getTarget(1))
  level:addMessage("You gaze into the prism. It shatters!", self.owner)

  -- TODO: Better way to do this
  game.interface:push(FeatsPanel(game.interface.display, game.interface, {conditions.Rapidfire, conditions.Swiftness}))

  self.owner.maxHP = self.owner.maxHP + 5
  self.owner.HP = self.owner.HP + 5
end

local Prism = Actor:extend()
Prism.name = "Prism of Enlightenment"
Prism.color = {0.67, 0.78, 0.9, 1}
Prism.emissive = true
Prism.char = Tiles["prism"]
Prism.lightEffect = components.Light.effects.pulse({ 0.4, 0.4, 0.6, 1 }, 0.2, 0.2)

Prism.components = {
  components.Light{
    color = { 0.4, 0.4, 0.6, 1},
    intensity = 4,
    effect = Prism.lightEffect
  },
  components.Item(),
  components.Usable{Gaze}
}

return Prism
