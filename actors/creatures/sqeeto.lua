local Actor = require "actor"
local Vector2 = require "vector"
local Tiles = require "tiles"

local Sqeeto = Actor:extend()

Sqeeto.char = Tiles["sqeeto"]
Sqeeto.name = "sqeeter"
Sqeeto.color = {0.8, 0.7, 0.09}

Sqeeto.components = {
  components.Sight{ range = 3, fov = true, explored = false },
  components.Move(),
  components.Stats
  {
    STR = 8,
    DEX = 10,
    INT = 4,
    CON = 8,
    maxHP = 3,
    AC = 13
  },

  components.Attacker
  {
    defaultAttack =
    {
      name = "Probiscus",
      stat = "DEX",
      dice = "1d1"
    }
  },

  components.Aicontroller()
}

local actUtil = components.Aicontroller
function Sqeeto:act(level)
  local highest = 0
  local highestActor = nil
  local wowFactor = false

  local function playAnim(animateBool, x, y)
    if not animateBool then return end
    level:addEffect(effects.Character(x, y - 1, Tiles["bubble_surprise"], {1, 1, 1}, .5))
  end

  for k, v in pairs(self.seenActors) do
    if v:is(actors.Player) and self:getRange("box", v) == 1 then
      return self:getAction(actions.Attack)(self, v)
    elseif v:hasComponent(components.Light) then
      local lightVal = ROT.Color.value(v.light) * v.lightIntensity

      if lightVal > highest then
        highest = lightVal
        highestActor = v
      end
    end
  end

  local x, y, brightest = actUtil.getLightestTile(level, self)

  if highestActor then
    if not (highestActor == self.actTarget) then
      wowFactor = true
    end
    self.actTarget = highestActor
  end

  if self.actTarget then
    if brightest > ROT.Color.value(self.actTarget.light) * self.actTarget.lightIntensity then
      self.actTarget = nil
    else
      if math.random() > .75 then
        local action, moveVec = actUtil.randomMove(level, self)
        playAnim(wowFactor, self.position.x + moveVec.x, self.position.y + moveVec.y)
        return action
      end

      local action, moveVec = actUtil.moveTowardObject(self, self.actTarget)
      playAnim(wowFactor, self.position.x + moveVec.x, self.position.y + moveVec.y)
      return action
    end
  end

  return actUtil.moveTowardLight(level, self)
end

return Sqeeto
