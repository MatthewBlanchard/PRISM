local Controller = require "components.controller"
local Vector2 = require "vector"

local AIController = Controller:extend()
AIController.name = "AIController"
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

function AIController.getPassableDirection(actor)
  local options = {}

  local x, y = actor.position.x, actor.position.y
  for i = -1, 1 do
    for j = -1, 1 do
      if actor.fov[x+i][y+j] == 0 and not (i == 0 and j == 0) then
        table.insert(options, {i, j})
      end
    end
  end

  return Vector2(unpack(options[love.math.random(1, #options)]))
end

function AIController.moveTowardSimple(actor, target)
  local mx = target.position.x - actor.position.x > 0 and 1 or target.position.x - actor.position.x < 0 and - 1 or 0
  local my = target.position.y - actor.position.y > 0 and 1 or target.position.y - actor.position.y < 0 and - 1 or 0

  local moveVec = Vector2(mx, my)
  return actor:getAction(actions.Move)(actor, moveVec)
end


function AIController.moveTowardObject(actor, target)
  local mx = target.position.x - actor.position.x > 0 and 1 or target.position.x - actor.position.x < 0 and - 1 or 0
  local my = target.position.y - actor.position.y > 0 and 1 or target.position.y - actor.position.y < 0 and - 1 or 0

  if actor.fov[actor.position.x + mx][actor.position.x + my] == 0 then
    local moveVec = Vector2(mx, my)
    return actor:getAction(actions.Move)(actor, moveVec), moveVec
  end

  local closestDist = target:getRange("box", actor)
  local closest = {x = actor.position.x, y = actor.position.y}
  local current = {x = actor.position.x, y = actor.position.y}
  for x = actor.position.x - 1, actor.position.x + 1 do
    for y = actor.position.y - 1, actor.position.y + 1 do
      current.x, current.y = x, y
      local dist = target:getRange("box", current)

      if dist < closestDist and AIController.isPassable(actor, current) and not (x == target.position.x or y == target.position.y) then
        closestDist = dist
        closest.x, closest.y = current.x, current.y
      end
    end
  end

  local moveVec = Vector2(-(actor.position.x - closest.x), -(actor.position.y - closest.y))
  return actor:getAction(actions.Move)(actor, moveVec), moveVec
end

function AIController.move(actor, moveVec)
    return actor:getAction(actions.Move)(actor, moveVec)
end

function AIController.tileHasCreature(actor, current)
  for _, seen in ipairs(actor.seenActors) do
    if seen.position.x == current.x and seen.position.y == current.y  then
      return true
    end
  end

  return false
end

function AIController.moveToward(actor, target, avoidCreatures)
  local mx = target.position.x - actor.position.x > 0 and 1 or target.position.x - actor.position.x < 0 and - 1 or 0
  local my = target.position.y - actor.position.y > 0 and 1 or target.position.y - actor.position.y < 0 and - 1 or 0

  if actor.fov[actor.position.x + mx][actor.position.x + my] == 0 then
    local moveVec = Vector2(mx, my)
    return actor:getAction(actions.Move)(actor, moveVec), moveVec
  end

  local closestDist = target:getRange("box", actor)
  local closest = {x = actor.position.x, y = actor.position.y}
  local current = {x = actor.position.x, y = actor.position.y}
  for x = actor.position.x - 1, actor.position.x + 1 do
    for y = actor.position.y - 1, actor.position.y + 1 do
      current.x, current.y = x, y
      local dist = target:getRange("box", current)

      if dist < closestDist and AIController.isPassable(actor, current) then
        if avoidCreatures and not AIController.tileHasCreature(actor, current) then
          closestDist = dist
          closest.x, closest.y = current.x, current.y
        elseif not avoidCreatures then
          closestDist = dist
          closest.x, closest.y = current.x, current.y
        end
      end
    end
  end

  local moveVec = Vector2(-(actor.position.x - closest.x), -(actor.position.y - closest.y))
  return actor:getAction(actions.Move)(actor, moveVec), moveVec
end

function AIController.crowdAround(actor, target, avoidCreatures)
  if actor.position.x == target.position.x and actor.position.y and target.position.y then
    local moveVec = Vector2(0, 0)
    return actor:getAction(actions.Move)(actor, moveVec), moveVec
  end

  local openTiles = {}
  for x = actor.position.x - 1, actor.position.x + 1 do
    for y = actor.position.y - 1, actor.position.y + 1 do
      local current = {x = x, y = y}
      if AIController.isPassable(actor, current) and not AIController.tileHasCreature(actor, current) then
        table.insert(openTiles, current)
      end
    end
  end

  local closest = math.huge
  local closestVec = {x = actor.position.x, y = actor.position.y}

  for i = 1, #openTiles do
    local range = math.max(target:getRange("box", openTiles[i]), 1)
    if openTiles[i].x == actor.position.x and openTiles.y == actor.position.y then
      if range <= closest then
        closest = range
        closestVec = openTiles[i]
      end
    else
      if range < closest then
        closest = range
        closestVec = openTiles[i]
      end
    end
  end

  local moveVec = Vector2(-(actor.position.x - closestVec.x), -(actor.position.y - closestVec.y))
  return actor:getAction(actions.Move)(actor, moveVec), moveVec
end


function AIController.moveAway(actor, target)
  local mx = target.position.x - actor.position.x > 0 and -1 or target.position.x - actor.position.x < 0 and 1 or 0
  local my = target.position.y - actor.position.y > 0 and -1 or target.position.y - actor.position.y < 0 and 1 or 0

  if actor.fov[actor.position.x + mx][actor.position.x + my] == 0 then
    local moveVec = Vector2(mx, my)
    return actor:getAction(actions.Move)(actor, moveVec), moveVec
  end

  local furthestDist = target:getRange("box", actor)
  local closest = {x = actor.position.x, y = actor.position.y}
  local current = {x = actor.position.x, y = actor.position.y}
  for x = actor.position.x - 1, actor.position.x + 1 do
    for y = actor.position.y - 1, actor.position.y + 1 do
      current.x, current.y = x, y
      local dist = target:getRange("box", current)

      if dist > furthestDist and AIController.isPassable(actor, current) then
        furthestDist = dist
        closest.x, closest.y = current.x, current.y
      end
    end
  end

  local moveVec = Vector2(-(actor.position.x - closest.x), -(actor.position.y - closest.y))
  return actor:getAction(actions.Move)(actor, moveVec), moveVec
end

function AIController.canSeeActor(actor, target)
  for k, v in pairs(actor.seenActors) do
    if v == actor then return true end
  end

  return false
end

function AIController.canSeeActorType(actor, type)
  for k, v in pairs(actor.seenActors) do
    if v:is(type) then return true end
  end

  return false
end


function AIController.closestSeenActorByType(actor, type)
  local closest
  local dist = math.huge
  for k, v in pairs(actor.seenActors) do
    if v:is(type) and v:getRange("box", actor) < dist then
      closest = v
      dist = v:getRange("box", actor)
    end
  end

  return closest
end

function AIController.getLightestTile(level, actor)
  local highestLightValue = 0
  local highest = {x = actor.position.x, y = actor.position.y}
  for x = actor.position.x - 1, actor.position.x + 1 do
    for y = actor.position.y - 1, actor.position.y + 1 do
      if level.light[x] and level.light[x][y] then
        local lightval = ROT.Color.value(level.light[x][y])

        if lightval > highestLightValue and AIController.isPassable(actor, {x = x, y = y}) and
        level.map[x] and level.map[x][y] == 0 then
          highestLightValue = lightval
          highest.x, highest.y = x, y
        end
      end
    end
  end

  return highest.x, highest.y, highestLightValue
end

function AIController.moveTowardLight(level, actor)
  local x,y, lightVal = AIController.getLightestTile(level, actor)

  local moveVec = Vector2(-(actor.position.x - x), -(actor.position.y - y))
  return actor:getAction(actions.Move)(actor, moveVec)
end

function AIController.randomMove(level, actor)
  local moveVec = Vector2(ROT.RNG:random(1, 3) - 2, ROT.RNG:random(1, 3) - 2)
  return actor:getAction(actions.Move)(actor, moveVec), moveVec
end

return AIController
