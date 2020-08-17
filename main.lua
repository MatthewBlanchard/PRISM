ROT = require 'src.rot'

conditions = {}
reactions = {}
actions = {}
components = {}
actors = {}
effects = require "effects"

love.graphics.setDefaultFilter("nearest", "nearest")
local function loadItems(directoryName, items, recurse)
  local info = {}

  for k, item in pairs(love.filesystem.getDirectoryItems(directoryName)) do
    local fileName = directoryName .. "/" .. item
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
  local scale = 1
  local w, h = math.floor(81/scale), math.floor(49/scale)
  local display = Display:new(w, h, scale, nil, {.09, .09, .09}, nil, nil, true)
  local map = ROT.Map.Rogue(display:getWidth() - 11, 44)

  game.display = display

  local interface = Interface(display)
  local level = Level(map)

  game.level = level
  game.interface = interface

  local spawnActor = function(actor)
    local x, y = level:getRandomWalkableTile()
    actor.position.x = x
    actor.position.y = y
    level:addActor(actor)
  end

  for i = 1, 15 do
    spawnActor(actors.Sqeeto())
  end

  for i = 1, 5 do 
    spawnActor(actors.Golem())
  end

  for i = 1, 5 do
    spawnActor(actors.Potion())
  end

  local chestContents = {
    actors.Ring_of_protection,
    actors.Ring_of_regeneration,
    actors.Armor,
    actors.Cloak_of_invisibility,
    actors.Slippers_of_swiftness,
    actors.Wand_of_lethargy,
    actors.Wand_of_swapping,
    actors.Wand_of_random_teleportation,
    actors.Potion_of_weight,
    actors.Potion_of_rage,
    actors.Dagger_of_venom
  }

  for i = 1, 4 do
    local chest = actors.Chest()
    table.insert(chest.inventory, chestContents[math.random(#chestContents)]())
    spawnActor(chest)
  end

  for i = 1, 10 do 
    spawnActor(actors.Shard())
  end

  local chest = actors.Chest()
  local key = actors.Key()
  chest:setKey(chest, key)

  spawnActor(chest)
  spawnActor(actors.Prism())
  local player = actors.Player()
  spawnActor(player)

  table.insert(player.inventory, actors.Prism())
  table.insert(player.inventory, actors.Parsnip())
  table.insert(player.inventory, actors.Parsnip())
  table.insert(player.inventory, actors.Dagger_of_venom())
  table.insert(player.inventory, actors.Wand_of_fireball())
  love.keyboard.setKeyRepeat(true)
end

function love.draw()
  if not game.display then return end
  game.display:clear()
  game.interface:draw(game.display)
  game.display:draw()
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
  if not game.curActor then return end
  game.interface:handleKeyPress(key, scancode)
end
