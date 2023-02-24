local Actor = require "actor"
local Vector2 = require "vector"
local Tiles = require "tiles"

local Sqeeto = Actor:extend()

Sqeeto.char = Tiles["sqeeto"]
Sqeeto.name = "sqeeter"
Sqeeto.color = {0.8, 0.7, 0.09}
Sqeeto.passable = false

Sqeeto.components = {
  components.Sight{ range = 4, fov = true, explored = false, darkvision = 0.25 },
  components.Move{ speed = 100 },
  components.Stats{
    ATK = 0,
    MGK = 0,
    PR = 0,
    MR = 0,
    maxHP = 3,
    AC = 2
  },

  components.Attacker{
    defaultAttack =
    {
      name = "Probiscus",
      stat = "ATK",
      dice = "1d1"
    }
  },

  components.Aicontroller(),
  components.Animated()
}

local actUtil = components.Aicontroller
function Sqeeto:act(level)
  local highest = 0
  local highestActor = nil
  local wowFactor = false

  local function playAnim(animateBool, actor)
    if not animateBool then return end
    level:addEffectAfterAction(effects.CharacterDynamic(actor, 0, -1, Tiles["bubble_surprise"], {1, 1, 1}, .5))
  end

  for k, v in pairs(self.seenActors) do
    local light_component = v:getComponent(components.Light)
    if v:is(actors.Player) and self:getRange("box", v) == 1 then
      return self:getAction(actions.Attack)(self, v)
    elseif light_component then
      local lightVal = ROT.Color.value(light_component.color) * light_component.intensity

      if lightVal > highest then
        highest = lightVal
        highestActor = v
      end
    end
  end

  local x, y, brightest = actUtil.getLightestTile(level, self)
  local spider = actUtil.closestSeenActorByType(self, actors.Webweaver)
  if highestActor then
    if not (highestActor == self.actTarget) then
      wowFactor = true
    end
    self.actTarget = highestActor
  else
    self.actTarget = nil
  end

  if spider then
    level:addEffect(effects.CharacterDynamic(self, 0, -1, Tiles["bubble_lines"], {1, 1, 1}, .5))
    return actUtil.moveAway(self, spider)
  end

  if self.actTarget then
    local light_component = self.actTarget:getComponent(components.Light)
    if brightest > ROT.Color.value(light_component.color) * light_component.intensity then
      self.actTarget = nil
    else
      if math.random() > .75 then
        local action, moveVec = actUtil.randomMove(level, self)
        playAnim(wowFactor, self)
        return action
      end

      local action, moveVec = actUtil.moveTowardObject(self, self.actTarget)
      playAnim(wowFactor, self)
      return action
    end
  end

  return actUtil.moveTowardLight(level, self)
end

return Sqeeto
