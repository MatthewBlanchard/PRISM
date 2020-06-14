ROT = require 'src.rot'

conditions = {}
reactions = {}
actions = {}
components = {}
actors = {}
effects = require "effects"


local function loadItems(directoryName, items, recurse)
  local info = {}

  for k, item in pairs(love.filesystem.getDirectoryItems(directoryName)) do
    fileName = directoryName .. "/" .. item
    love.filesystem.getInfo(fileName, info)
    if info.type == "file" then
      fileName = string.gsub(fileName, ".lua", "")
      local name = string.gsub(item:sub(1, 1):upper()..item:sub(2), ".lua", "")

      items[name] = require(fileName)
    elseif info.type == "directory" and recurse then
      loadItems(fileName, items)
    end
  end
end

loadItems("components", components)
targets = require "target"
loadItems("actions", actions, false)
loadItems("actions/reactions", reactions, true)
loadItems("conditions", conditions, true)
loadItems("actors", actors, true)

local Level = require "level"
local Interface = require "interface"
local Display = require "display.display"

------
-- Global

game = {}


function love.load()
  display = Display:new(81, 49, 1, nil, {.09, .09, .09}, nil, nil, true)
  map = ROT.Map.Rogue(display:getWidth() - 11, 44)

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

  local chestContents = {
    actors.Ring_of_protection,
    actors.Ring_of_regeneration,
    actors.Armor,
    actors.Cloak_of_invisibility,
    actors.Slippers_of_swiftness,
    actors.Wand_of_lethargy,
    actors.Wand_of_swapping,
    actors.Wand_of_random_teleportation
  }
  for i = 1, 4 do
    local chest = actors.Chest()
    table.insert(chest.inventory, chestContents[math.random(#chestContents)]())
    local x, y = level:getRandomWalkableTile()
    chest.position.x = x
    chest.position.y = y
    level:addActor(chest)
  end

  local chest = actors.Chest()
  local key = actors.Key()
  local x, y = level:getRandomWalkableTile()
  chest.position.x = x
  chest.position.y = y
  chest:setKey(chest, key)
  level:addActor(chest)

  table.insert(player.inventory, key)
  table.insert(player.inventory, actors.Parsnip())
  table.insert(player.inventory, actors.Dagger_of_venom())
  love.keyboard.setKeyRepeat(true)
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
