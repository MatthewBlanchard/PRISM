ROT = require 'src.rot'

conditions = {}
reactions = {}
actions = {}
components = {}
actors = {}

-- This is horrible please stop.
local info = {}

targets = require "target"

for k, item in pairs(love.filesystem.getDirectoryItems("actions")) do
    fileName = "actions/" .. item
    love.filesystem.getInfo(fileName, info)
    if info.type == "file" then
        fileName = string.gsub(fileName, ".lua", "")
        local name = string.gsub(item:sub(1,1):upper()..item:sub(2), ".lua", "")

        actions[name] = require(fileName)
    end
end

for k, item in pairs(love.filesystem.getDirectoryItems("actions/reactions")) do
    fileName = "actions/reactions/" .. item
    love.filesystem.getInfo(fileName, info)
    if info.type == "file" then
        fileName = string.gsub(fileName, ".lua", "")
        local name = string.gsub(item:sub(1,1):upper()..item:sub(2), ".lua", "")

        reactions[name] = require(fileName)
    end
end

for k, item in pairs(love.filesystem.getDirectoryItems("components")) do
    fileName = "components/" .. item
    love.filesystem.getInfo(fileName, info)
    if info.type == "file" then
        fileName = string.gsub(fileName, ".lua", "")
        local name = string.gsub(item:sub(1,1):upper()..item:sub(2), ".lua", "")

        components[name] = require(fileName)
    end
end


for k, item in pairs(love.filesystem.getDirectoryItems("conditions")) do
    fileName = "conditions/" .. item
    love.filesystem.getInfo(fileName, info)
    if info.type == "file" then
        fileName = string.gsub(fileName, ".lua", "")
        local name = string.gsub(item:sub(1,1):upper()..item:sub(2), ".lua", "")

        conditions[name] = require(fileName)
    end
end

for k, item in pairs(love.filesystem.getDirectoryItems("actors")) do
    fileName = "actors/" .. item
    love.filesystem.getInfo(fileName, info)
    if info.type == "file" then
        fileName = string.gsub(fileName, ".lua", "")
        local name = string.gsub(item:sub(1,1):upper()..item:sub(2), ".lua", "")

        actors[name] = require(fileName)
    end
end

local Level = require "level"
local Interface = require "interface"

------
-- Global

game = {}


function love.load()
    display = ROT.Display(66, 66, 1, nil, {.09, .09, .09})
    map = ROT.Map.Rogue(display:getWidth(), 50)

    local interface = Interface(display)
    local level = Level(map)

    game.level = level
    game.interface = interface

    player = actors.Player()
    local x, y = level:getRandomWalkableTile()
    player.position.x = x
    player.position.y = y
    level:addActor(player)

    for i = 1, 20 do
        local monster = actors.Monster()
        local x, y = level:getRandomWalkableTile()
        monster.position.x = x
        monster.position.y = y
        level:addActor(monster)
    end

    for i = 1, 5 do
        local potion = actors.Potion()
        local x, y = level:getRandomWalkableTile()
        potion.position.x = x
        potion.position.y = y
        level:addActor(potion)
    end

    local potion = actors.Potion()
    local armor = actors.Armor()
    table.insert(player.inventory, potion)
    table.insert(player.inventory, armor)
end

function love.draw()
    display:clear()
        game.interface:draw(display)
    display:draw()
end

function love.update(dt)
  local curActor
  while not curActor and (#game.level.effects == 0) do
    curActor = game.level:update(dt, game.interface:getAction())
  end

  game.curActor = game.curActor or curActor
  game.interface:update(dt, game.level)
end

function love.keypressed(key, scancode)
    game.interface:handleKeyPress(key, scancode)
end
