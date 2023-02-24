local Actor = require "actor"
local Condition = require "condition"

local Player = Actor:extend()
Player.name = "Player"
Player.passable = false

Player.components = {
  components.Sight{ range = 30, fov = true, explored = true },
  components.Message(),
  components.Move{ speed = 100 },
  components.Inventory(),
  components.Wallet{ autoPick = true },
  components.Controller{ inputControlled = true },

  components.Stats{
    ATK = 0,
    MGK = 0,
    PR = 0,
    MR = 0,
    maxHP = 10,
    AC = 0
  },

  components.Progression(),

  components.Attacker{
    defaultAttack =
    {
      name = "Stronk Fists",
      stat = "ATK",
      dice = "1d1"
    }
  },


  components.Equipper {
    "body",
    "head",
    "offhand",
    "ring",
    "feet",
    "cloak"
  },

  components.Animated()
}
return Player
