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
local Start = require "panels.start"

------
-- Global

game = {}


function love.load()
  min_dt = 1/30 --fps
  next_time = love.timer.getTime()

  local scale = 1
  local w, h = math.floor(81/scale), math.floor(49/scale)
  local w2, h2 = math.floor(81/2), math.floor(49/2)
  local display = Display:new(w, h, scale, nil, {.09, .09, .09, 0}, nil, nil, true)
  local viewDisplay2x = Display:new(w2, h2, 2, nil, {.09, .09, .09}, nil, nil, true)
  local viewDisplay1x = Display:new(w, h, 1, nil, {.09, .09, .09}, nil, nil, true)
  local map = ROT.Map.Brogue(display:getWidth() - 11, 44)

  game.display = display
  game.viewDisplay1x = viewDisplay1x
  game.viewDisplay2x = viewDisplay2x
  game.viewDisplay = viewDisplay2x
  game.Player = actors.Player()

  local interface = Interface(display)
  interface:push(Start(display, interface))
  local level = Level(map)

  game.level = level
  game.interface = interface

  local player = game.Player
  table.insert(player.inventory, actors.Wand_of_light())
  table.insert(player.inventory, actors.Jerkin_of_grease())

  love.keyboard.setKeyRepeat(true)
end

function love.draw()
  if not game.display then return end
  game.viewDisplay:clear()
  game.display:clear()
  game.interface:draw(game.display)
  game.viewDisplay:draw()
  game.display:draw()
end

function love.update(dt)
  next_time = next_time + min_dt

  local curActor
  while not curActor and (#game.level.effects == 0) do
    curActor = game.level:update(dt, game.interface:getAction())
  end

  if curActor == true then
    local map = ROT.Map.Brogue(game.display:getWidth() - 11, 44)
    game.level = Level(map)
    game.Player.explored = {}
  end

  game.curActor = game.curActor or curActor
  game.interface:update(dt, game.level)
end

function love.keypressed(key, scancode)
  if not game.curActor then return end
  game.interface:handleKeyPress(key, scancode)
end
