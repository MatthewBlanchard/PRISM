local System = require "system"

--- The Sight System manages the sight of actors. It is responsible for updating the FOV of actors, and
--- keeping track of which actors are visible to each other.
local SightSystem = System:extend()
SightSystem.name = "Sight"

-- We want to run the sight system after the lighting system so that we can use the lighting system's
-- data to determine fov with darkvision. The sight system will still run if the lighting system is not
-- available.
SightSystem.softRequirements = {
    "Lighting"
}

--- Before an actor takes an action their visibility is tracked in the cache. After the action is taken
--- the visibility is compared to the cache to see if the actor's visibility has changed. After checking
--- the visibility the cache is cleared for that actor.
SightSystem.__visibilityCheck = nil

function SightSystem:__new()
    self.__visibilityCheck = {}
    self.__opaqueCheck = {}
end

function SightSystem:beforeAction(level, actor, action)
    for actor in level:eachActor() do
        self.__visibilityCheck[actor] = actor:isVisible()
        self.__opaqueCheck[actor] = actor.blocksVision
    end
end

function SightSystem:afterAction(level, actor, action)
    if action:is(actions.Move) then return end

    local should_rebuild_seen = false
    local should_rebuild_fov = false
    -- if the actor's visibility has changed we need to update the visibility of all actors
    -- who can see the actor
    for actor in level:eachActor() do
        if self.__visibilityCheck[actor] ~= actor:isVisible() then
            should_rebuild_seen = true
            self.__visibilityCheck[actor] = nil
        end

        if self.__opaqueCheck[actor] ~= actor.blocksVision then
            should_rebuild_fov = true
            self.__opaqueCheck[actor] = nil
        end
    end

    if should_rebuild_fov then
        for actor in level:eachActor() do
            self:updateFOV(level, actor)
        end
    elseif should_rebuild_seen then
        for actor in level:eachActor() do
            self:updateSeenActors(level, actor)
        end
    end
end

function SightSystem:onMove(level, actor, from, to)
    self:updateFOV(level, actor)

    for other_actor in level:eachActor() do
        if other_actor ~= actor then
            if actor.blocksVision then
                self:updateFOV(level, other_actor)
            else
                self:updateSeenActors(level, other_actor)
            end
        end
    end
end

function SightSystem:onActorAdded(level, actor)
    self:updateFOV(level, actor)
end

-- These functions update the fov and visibility of actors on the level.
function SightSystem:updateFOV(level, actor)    
    -- check if actor has a sight component and if not return
    local sight_component = actor:getComponent(components.Sight)
    if not sight_component then 
        return 
    end

    local fovCalculator = ROT.FOV.Recursive(self:createVisibilityClosure(level))

    -- clear the actor visibility cache
    sight_component.seenActors = {}
  
    local sightLimit = sight_component.sight

    -- we check if the sight component has a fov and if so we clear it
    if sight_component.fov then
        sight_component.fov = {}

        local sightLimit = sight_component.range
        -- we check if the cell has a sight limit and if so we set the sight limit to the lowest sight limit
        -- between the actor and the cell
        if level:getCell(actor.position.x, actor.position.y).sightLimit then
            sightLimit = math.min(sightLimit, level:getCell(actor.position.x, actor.position.y).sightLimit)
        end
    
        fovCalculator:compute(actor.position.x, actor.position.y, sightLimit, self:createFOVClosure(level, sight_component))
    
        --[[
        -- if the level has the lighting system we check if the actor has a darkvision value and if so we update the fov
        -- to remove any cells that are in darkness
        local light_system = level:getSystem("Lighting")
        if light_system and sight_component.darkvision ~= 0 then 
            for x, _ in pairs(sight_component.fov) do
                for y, _ in pairs(sight_component.fov[x]) do
                local lightval = ROT.Color.value(light_system:getLightingAt(x, y, sight_component.fov) or {0, 0, 0})
                    if lightval < sight_component.darkvision or lightval ~= lightval then
                        sight_component.fov[x][y] = nil
                    end
                end
            end
        end
        --]]
    else
        -- we have a sight component but no fov which essentially means the actor has blind sight and can see
        -- all cells within a certain radius only generally only simple actors have this vision type
        for x = actor.position.x - sightLimit, actor.position.x + sightLimit do
            for y = actor.position.y - sightLimit, actor.position.y + sightLimit do
                if not sight_component.fov[x] then sight_component.fov[x] = {} end
                sight_component.fov[x][y] = level:getCell(x, y)
            end
        end
    end
  
    self:updateExplored(actor)
    self:updateSeenActors(level, actor)
    self:updateScryActors(actor)
end

function SightSystem:updateSeenActors(level, actor)
    -- if we don't have a sight component we return
    local sight_component = actor:getComponent(components.Sight)
    if not sight_component then return end

    -- clear the actor visibility cache
    sight_component.seenActors = {}

    -- we loop through all the actors on the level and check if they are visible to the actor
    for k, other in ipairs(level.actors) do
        if (other:isVisible() or actor == other) and sight_component:canSeeCell(other.position.x, other.position.y) then
            table.insert(sight_component.seenActors, other)
        end
    end
end

function SightSystem:updateExplored(actor)
    local sight_component = actor:getComponent(components.Sight)

    for x, _ in pairs(sight_component.fov) do
        for y, _ in pairs(sight_component.fov[x]) do
            sight_component:setCellExplored(x, y)
        end
    end
end


function SightSystem:updateScryActors(actor)
    actor.scryActors = {}
  
    -- we'll use this temporary table to remove duplicates
    local scryed = {}
  
    local dummy = {}
    for i, condition in ipairs(actor:getConditions()) do
      local e = condition:getActionEvents("onScrys", self) or dummy
      for i, event in ipairs(e) do
        local scryedActors = event:fire(condition, self, actor)
  
        for _, scryedActor in ipairs(scryedActors) do
          scryed[scryedActor] = true
        end
      end
    end
  
    for scryActor, _ in pairs(scryed) do
      table.insert(actor.scryActors, scryActor)
    end
end
  
-- Little factories for some callback functions we need to pass to the FOV calculator
function SightSystem:createVisibilityClosure(level)
    return function(fov, x, y)
        return level:getCellVisibility(x, y)
    end
end

function SightSystem:createFOVClosure(level, sight_component)
    return function(x, y, z)
        if not sight_component.fov[x] then sight_component.fov[x] = {} end
        sight_component.fov[x][y] = level:getCell(x, y)
    end
end

-- TODO: Generalize this so that cells can define their own visibility in 
-- relation to other cells
function SightSystem:grassCheck(actor, other)
    local otherid = self:getCell(other.position.x, other.position.y).grassID
    local id = self:getCell(actor.position.x, actor.position.y).grassID
  
    if not id and not otherid then return true end
    if not id and otherid then return false end
    if id and not otherid then return true end
    if id == otherid then return true end
    return false
  end
  

return SightSystem