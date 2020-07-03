local Actor = require "actor"
local Vector2 = require "vector"
local Tiles = require "tiles"

local Monster = Actor:extend()

Monster.char = Tiles["zombie"]
Monster.name = "zombie"
Monster.color = {90 / 230, 161 / 230, 74 / 230}

Monster.components = {
  components.Sight{ range = 12, fov = true, explored = false },
  components.Move(),
  components.Stats
  {
    STR = 10,
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
      name = "Claws",
      stat = "DEX",
      dice = "1d2"
    }
  },

  components.Aicontroller()
}

local actUtil = components.Aicontroller
function Monster:act()
  for _, actor in ipairs(self.seenActors) do
    if actor:is(actors.Player) then
      if self:getRange("box", actor) == 1 then
        return self:getAction(actions.Attack)(self, actor)
      end

      return actUtil.moveToward(self, actor)
    end
  end

  return self:getAction(actions.Move)(self, Vector2(ROT.RNG:random(1, 3) - 2, ROT.RNG:random(1, 3) - 2))
end

return Monster
