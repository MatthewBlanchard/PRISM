local Actor = require "actor"
local Condition = require "condition"

local Player = Actor:extend()
Player.name = "Player"

local lightEffect = components.Light.effects.flicker({ 0.8666, 0.4509, 0.0862, 1 }, .1, .1)
Player.components = {
  components.Light{
    color = { 0.8666, 0.4509, 0.0862, 1},
    intensity = 3,
    effect = lightEffect
  },
  components.Sight{ range = 30, fov = true, explored = true },
  components.Message(),
  components.Move{ speed = 100, passable = false },
  components.Inventory(),
  components.Wallet{ autoPick = true },
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
    "body",
    "head",
    "ring",
    "feet",
    "cloak"
  }
}
return Player
