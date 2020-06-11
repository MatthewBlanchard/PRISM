local Actor = require "actor"
local Vector2 = require "vector"
local Tiles = require "tiles"

local Monster = Actor:extend()

Monster.char = Tiles["zombie"]
Monster.name = "zombie"
Monster.color = {90 / 230, 161 / 230, 74 / 230}

Monster.components = {
  components.Sight{ range = 12, fov = true, explored = true },
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

function Monster:act()
  for k, v in pairs(self.seenActors) do
    if v:is(actors.Player) then
      if self:getRange("box", v) == 1 then
        return self:getAction(actions.Attack)(self, v)
      end

      local mx = v.position.x - self.position.x > 0 and 1 or v.position.x - self.position.x < 0 and - 1 or 0
      local my = v.position.y - self.position.y > 0 and 1 or v.position.y - self.position.y < 0 and - 1 or 0
      return self:getAction(actions.Move)(self, Vector2(mx, my))
    end
  end

  return self:getAction(actions.Move)(self, Vector2(ROT.RNG:random(1, 3) - 2, ROT.RNG:random(1, 3) - 2))
end

return Monster
