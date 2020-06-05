local Object = require "object"
local Vector2 = require "vector"

local Panel = require "panel"
local Inventory = require "panels.inventory"
local Status = require "panels.status"
local Message = require "panels.message"

local Interface = Panel()

function Interface:__new(display)
	Panel.__new(self, display)
	self.statusPanel = Status(display)
	self.messagePanel = Message(display)
	self.stack = {}
end

function Interface:update(dt)
	self.dt = dt
	self.messagePanel:update(dt)
	game.level:updateEffectLighting(dt)

	if #game.level.effects > 0 and not self.curEffect then
		self.curEffect = table.remove(game.level.effects, 1)
	end

	if not self:peek() then return end
	self:peek():update(dt)
end

local function value(c)
	return (c[1]+c[2]+c[3])/3
end

local function clerp(start, finish, t)
	local c = {}
	for i = 1, 4 do
		if not start[i] or not finish[i] then break end
		c[i] = (1 - t) * start[i] + t * finish[i]
	end

	return c
end

local function cmul(c1, s)
	return {c1[1] * s, c1[2] * s, c1[3] * s}
end

local function cadd(c1, c2)
	return {c1[1] + c2[1], c1[2] + c2[2], c1[3] + c2[3]}
end


local function csub(c1, c2)
	return {c1[1] - c2[1], c1[2] - c2[2], c1[3] - c2[3]}
end

function Interface:draw()
    local fov = game.curActor.fov
    local explored = game.curActor.explored
    local seenActors = game.curActor:getRevealedActors()
		local light = game.level.effectlight
		local ambientColor = {.175, .175, .175}

    for x = 1, game.level.width do
        for y = 1, game.level.height do
            if fov[x] and fov[x][y] then
                if light[x] and light[x][y] and value(light[x][y]) > .05 then
										-- okay we're gonna first establish our light color and then
										-- do a bit of blending to keep it in line with the ambient
										-- fog of war
										local finalColor
										local lightCol = light[x][y]
										local lightValue = value(lightCol)
										local inverseLightValue = math.abs(lightValue - 1)

										local ambientValue = value({.175, .375, .175})

										if lightValue < ambientValue then
											local t = 1 - lightValue / ambientValue
											finalColor = clerp(lightCol, ambientColor, t)
										else
											finalColor = lightCol
										end
                    self:write(fov[x][y] == 0 and "." or "#", x, y, finalColor)
                else
										local amCol =
                    self:write(fov[x][y] == 0 and "." or "#", x, y, ambientColor)
                end
            elseif explored[x] and explored[x][y] then
                self:write(explored[x][y] == 0 and "." or "#", x, y, ambientColor)
            end
        end
    end

    for k, actor in pairs(seenActors) do
    	local x, y = actor.position.x, actor.position.y
    	if light[x] and light[x][y] then
    		local lightValue = math.min(value(light[x][y]), 0.5)
    		self:write(actor.char, x, y, clerp(ambientColor, actor.color, lightValue/0.5))
    	end
    end

		if self.curEffect then
			local done = self.curEffect(self.dt, self)
			if done then self.curEffect = nil end
		end

    self.statusPanel:draw()
    self.messagePanel:draw()

		if not self:peek() then return end
		self:peek():draw()
end

local movementTranslation = {
	-- cardinal
	w = Vector2(0, -1),
	s = Vector2(0, 1),
	a = Vector2(-1, 0),
	d = Vector2(1, 0),

	-- diagonal
	q = Vector2(-1, -1),
	e = Vector2(1, -1),
	z = Vector2(-1, 1),
	c = Vector2(1, 1)
}

local keybinds = {
	i = "inventory",
	p = "pickup"
}

function Interface:handleKeyPress(keypress)
	if self:peek() then
		self:peek():handleKeyPress(keypress)
		return nil
	end

	if game.curActor:hasComponent(components.Inventory) then
		if keybinds[keypress] == "inventory" then
			self:push(Inventory(self.display, self))
		end

		if keybinds[keypress] == "pickup" then
			local item
			for k, i in pairs(game.curActor.seenActors) do
				if actions.Pickup:validateTarget(1, game.curActor, i) then
					return self:setAction(game.curActor:getAction(actions.Pickup)(game.curActor, i))
				end
			end
		end
	end

	-- we're dealing with a directional command here
	if movementTranslation[keypress] and game.curActor:hasComponent(components.Move) then
		local targetPosition = game.curActor.position + movementTranslation[keypress]

		local enemy
		for k, actor in pairs(game.curActor.seenActors) do
			if actor:hasComponent(components.Stats) and not actor.passable and actor.position == targetPosition then
				enemy = actor
			end

			if 	actor:hasComponent(components.Usable) and
			 		actor.defaultUseAction and
					actor.position == targetPosition and
					actor.defaultUseAction and
					actor.defaultUseAction:validateTarget(1, game.curActor, actor) and
					not actor.passable then
					return self:setAction(actor.defaultUseAction(game.curActor, actor))
			end
		end

		if enemy then
			return self:setAction(game.curActor:getAction(actions.Attack)(game.curActor, enemy))
		end

		return self:setAction(game.curActor:getAction(actions.Move)(game.curActor, movementTranslation[keypress]))
	end
end

function Interface:setAction(action)
	self.action = action
end

function Interface:getAction()
	local action = self.action
	self.action = nil
	return action
end

function Interface:push(panel)
	table.insert(self.stack, panel)
end

function Interface:pop()
	local panel = self.stack[#self.stack]
	self.stack[#self.stack] = nil
	return panel
end

function Interface:peek()
	return self.stack[#self.stack]
end

function Interface:reset()
	for i = 1, #self.stack do
		self.stack[i] = nil
	end
end

return Interface
