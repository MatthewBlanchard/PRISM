function Populater(level, map)
  local spawnedPrism = false
  local treasureRoom = false
  local toSpawn = {}
  local roomsLeft = #map._rooms - 1 -- subtract the starting room
  local doors = {}

  local function hash(x, y)
    return x and y * 0x4000000 + x or false --  26-bit x and y
  end

  local function spawnActor(room, actor, i, j)
    for i = 1, love.math.random(i, j) do
      spawnActor(room, actors.Shard())
    end
    local x, y = room:getRandomWalkableTile()
    actor.position.x = x
    actor.position.y = y
    level:addActor(actor)
  end

  local function moveActorToRoom(room, actor)
    local x, y = room:getRandomWalkableTile()
    actor.position.x = x
    actor.position.y = y
  end

  local function spawnDoors(room)
    for _, x, y in room._doors:each() do
      if not doors[hash(x, y)] then
        local door = actors.Door()
        door.position.x = x
        door.position.y = y

        level:addActor(door)
        doors[hash(x,y)] = true
      end
    end
  end

  local function spawnEnemies()
  end

  local function spawnShards(room, i, j)
    for i = 1, love.math.random(i, j) do
      spawnActor(room, actors.Shard())
    end
  end

  local function populateStartRoom(room)
    spawnDoors(room)
    spawnActor(room, game.Player)
  end

  local function populateTreasureRoom(room)
    local chestContents = {
      actors.Ring_of_protection,
      actors.Ring_of_regeneration,
      actors.Armor,
      actors.Cloak_of_invisibility,
      actors.Slippers_of_swiftness,
      actors.Wand_of_lethargy,
      actors.Wand_of_swapping,
      actors.Wand_of_random_teleportation,
      actors.Dagger_of_venom
    }

    treasureRoom = true
    local locked = false

    if roomsLeft <= #toSpawn then
      locked = false
    elseif love.math.random() > .5 then
      locked = true
    end

    local chest = actors.Chest()
    local key = actors.Key()

    table.insert(chest.inventory, chestContents[math.random(#chestContents)]())

    chest:setKey(key)
    spawnActor(room, chest)
    table.insert(toSpawn, key)

    spawnShards(room, 3, 10)
  end

  local function populateRoom(room)
    spawnDoors(room)

    if #room._doors == 2 and not treasureRoom then
      populateTreasureRoom(room)
      return
    end

    if roomsLeft <= #toSpawn and not (#toSpawn == 0) then
      local actor = table.remove(toSpawn, 1)
      spawnActor(room, actor)
      room.actors = room.actors or {}
      table.insert(room.actors, actor)
    end

    spawnShards(room, 0, 2)
    spawnActor(room, actors.Sqeeto())
  end

  table.insert(toSpawn, actors.Prism())

  local startRoom = table.remove(map._rooms, love.math.random(1, #map._rooms))

  for _, room in ipairs(map._rooms) do
    roomsLeft = roomsLeft - 1
    populateRoom(room)
  end

  populateStartRoom(startRoom)
end

return Populater
