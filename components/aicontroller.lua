local Controller = require "components.controller"
local Vector2 = require "vector"

local AIController = Controller:extend()
AIController.inputControlled = false

function AIController:__new(options)
  self.act = options and options.act or self.act
end

function AIController:initialize(actor)
  actor.act = self.act
end

function AIController.isPassable(actor, vec)
  if actor.fov[vec.x][vec.y] == 1 then
    return false
  end

  for _, seen in ipairs(actor.seenActors) do
    if seen.position.x == vec.x and seen.position.y == vec.y and not seen.passable and seen ~= actor then
      return false
    end
  end

  return true
end

function AIController.moveTowardSimple(actor, target)
  local mx = target.position.x - actor.position.x > 0 and 1 or target.position.x - actor.position.x < 0 and - 1 or 0
  local my = target.position.y - actor.position.y > 0 and 1 or target.position.y - actor.position.y < 0 and - 1 or 0

  local moveVec = Vector2(mx, my)
  return actor:getAction(actions.Move)(actor, moveVec)
end

function AIController.moveToward(actor, target)
  local mx = target.position.x - actor.position.x > 0 and 1 or target.position.x - actor.position.x < 0 and - 1 or 0
  local my = target.position.y - actor.position.y > 0 and 1 or target.position.y - actor.position.y < 0 and - 1 or 0

  if actor.fov[actor.position.x + mx][actor.position.x + my] == 0 then
    local moveVec = Vector2(mx, my)
    return actor:getAction(actions.Move)(actor, moveVec)
  end

  local closestDist = target:getRange("box", actor)
  local closest = {x = actor.position.x, y = actor.position.y}
  local current = {x = actor.position.x, y = actor.position.y}
  for x = actor.position.x - 1, actor.position.x + 1 do
    for y = actor.position.y - 1, actor.position.y + 1 do
      current.x, current.y = x, y
      local dist = target:getRange("box", current)

      if dist < closestDist and AIController.isPassable(actor, current) then
        closestDist = dist
        closest.x, closest.y = current.x, current.y
      end
    end
  end

  local moveVec = Vector2(-(actor.position.x - closest.x), -(actor.position.y - closest.y))
  return actor:getAction(actions.Move)(actor, moveVec)
end

function AIController.canSeeActor(actor, target)
  for k, v in pairs(actor.seenActors) do
    if v == actor then return true end
  end

  return false
end

local function cval(color) 
  local highest = color[1]
  for i = 1, 3 do
    if color[i] > highest then highest = color[i] end
  end

  return highest
end

function AIController.moveTowardLight(level, actor)
  local highestLightValue = 0
  local highest = {x = actor.position.x, y = actor.position.y}
  for x = actor.position.x - 1, actor.position.x + 1 do
    for y = actor.position.y - 1, actor.position.y + 1 do
      if level.light[x] and level.light[x][y] then
        local lightval = cval(level.light[x][y])

        if lightval > highestLightValue and AIController.isPassable(actor, {x = x, y = y}) then
          highestLightValue = lightval
          highest.x, highest.y = x, y
        end
      end
    end
  end

  local moveVec = Vector2(-(actor.position.x - highest.x), -(actor.position.y - highest.y))
  return actor:getAction(actions.Move)(actor, moveVec)
end

return AIController
