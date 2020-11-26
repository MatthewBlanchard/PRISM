ROT = require 'src.rot'
MusicManager = require "musicmanager"
vector22 = require "vector"

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
      loadItems(fileName, items, recurse)
    end
  end
end

loadItems("components", components)
targets = require "target"
loadItems("actions", actions, false)
loadItems("actions/reactions", reactions, true)
loadItems("conditions", conditions, true)
loadItems("actors", actors, true)
Loot = require "loot"

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
  local display = Display:new(w, h, scale, nil, {1, 1, 1, 0}, nil, nil, true)
  local viewDisplay2x = Display:new(w2, h2, 2, nil, {.09, .09, .09}, nil, nil, true)
  local viewDisplay1x = Display:new(w, h, 1, nil, {.09, .09, .09}, nil, nil, true)
  local map = ROT.Map.Brogue(display:getWidth() - 11, 44)

  game.music = MusicManager()
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
  game.curActor = player
  table.insert(player.inventory, actors.Wand_of_blastin())
  table.insert(player.inventory, actors.Robe_of_wonders())
  table.insert(player.inventory, actors.Circlet_of_channeling())
  table.insert(player.inventory, actors.Prism())
  table.insert(player.inventory, actors.Axe())

  love.keyboard.setKeyRepeat(true)
end

function love.draw()
  if not game.display then return end
  game.viewDisplay:clear()
  game.display:clear()
  game.interface:draw(game.display)
  game.viewDisplay:draw()
  game.display:draw("UI")
end

local storedKeypress
local updateCoroutine
game.waiting = false
local animations = true
function love.update(dt)
  game.level:updateEffectLighting(dt)
  game.music:update(dt)
  game.interface:update(dt, game.level)

  if not updateCoroutine then
    updateCoroutine = coroutine.create(game.level.update)
  end

  local awaitedAction = game.interface:getAction()

  -- we're waiting and there's no input so stop advancing
  if game.waiting and not awaitedAction then return end
  game.waiting = false

  -- don't advance game state while we're rendering effects please
  if #game.level.effects ~= 0 then return end

  local success, ret, effect = coroutine.resume(updateCoroutine, game.level, awaitedAction)
  if not game.interface.animating and success and ret == "effect" then
    while success and ret == "effect" do
      success, ret = coroutine.resume(updateCoroutine, game.level, awaitedAction)
    end
  end

  if success == false then
    error(ret .. debug.traceback(updateCoroutine))
  end

  game.interface.effects = {}

  if coroutine.status(updateCoroutine) == "suspended" then
    -- if level update returns a table we know we've got out guy so we set
    -- curActor to let the interface know to unlock input
    if type(ret) == "table" then
      game.curActor = ret
      game.waiting = true
      if storedKeypress then
        love.keypressed(storedKeypress[1], storedKeypress[2])
      end

      game.level.effects = {}
      game.interface.animating = true
    end
  end

  if coroutine.status(updateCoroutine) == "dead" then
    -- The coroutine has not stopped running and returned "descend".
    -- It's time for us to load a new level.
    if ret == "descend" then
      local map = ROT.Map.Brogue(game.display:getWidth() - 11, 44)
      game.level = Level(map)
      game.Player.explored = {}
    end

    updateCoroutine = coroutine.create(game.level.update)
  end
end

function love.keypressed(key, scancode)
  if not game.waiting then
    game.interface.animating = false
    game.interface.effects = {}
    storedKeypress = {key, scancode}
    return
  end

  storedKeypress = nil
  -- if there is no current actor than we freeze input
  game.interface:handleKeyPress(key, scancode)
end
