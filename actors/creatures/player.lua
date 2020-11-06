local Actor = require "actor"
local Condition = require "condition"

local Player = Actor:extend()
Player.name = "Player"

local lightEffect = components.Light.effects.flicker({ 0.8666, 0.4509, 0.0862, 1 }, .1, .1)
Player.components = {
  components.Light({ 0.8666, 0.4509, 0.0862, 1}, 3, lightEffect),
  components.Sight{ range = 30, fov = true, explored = true },
  components.Message(),
  components.Move(),
  components.Inventory(),
  components.Wallet(),
  components.Controller{ inputControlled = true },

  components.Stats
  {
    STR = 10,
    DEX = 10,
    INT = 10,
    CON = 10,
    WIS = 10,
    maxHP = 10,
    AC = 10
  },

  components.Progression(),

  components.Attacker
  {
    defaultAttack =
    {
      name = "Stronk Fists",
      stat = "STR",
      dice = "1d1"
    }
  },


  components.Equipper {
    "armor",
    "ring",
    "boots",
    "cloak"
  }
}

local Pickup = Condition:extend()
Pickup:afterAction(actions.Move,
  function(self, level, actor, action)
    for _,item in pairs(game.curActor.seenActors) do
      if actor:is(actors.Shard) and actions.Pickup:validateTarget(1, actor, item) then
        return level:performAction(game.curActor:getAction(actions.Pickup)(actor, item))
      end
    end
  end
)

Player.innateConditions = { 
  Pickup() 
}

return Player
