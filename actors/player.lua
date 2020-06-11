local Actor = require "actor"

local Player = Actor:extend()
Player.name = "Player"

local lightEffect = components.Light.effects.flicker({ 0.8666, 0.4509, 0.0862, 1 }, .1, .1)
Player.components = {
  components.Light({ 0.8666, 0.4509, 0.0862, 1 }, 3, lightEffect),
  components.Sight{ range = 30, fov = true, explored = true },
  components.Message(),
  components.Move(),
  components.Inventory(),
  components.Controller{ inputControlled = true },

  components.Stats
  {
    STR = 20,
    DEX = 10,
    INT = 10,
    CON = 10,
    maxHP = 10,
    AC = 10
  },

  components.Attacker
  {
    defaultAttack = 
    {
      name = "Short Sword",
      stat = "STR",
      dice = "3d6"
    }
  },


  components.Equipper{
    "armor",
    "ring",
    "cloak"
  }
}

return Player
