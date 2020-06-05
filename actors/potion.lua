local Actor = require "actor"
local Action = require "action"
local Condition = require "condition"

local function DrinkEffect(actor, heal)
	local t = 0
	local lastflip = 9
	return function(dt, interface)
		t = t + dt

		interface:write(dmgstring, position.x + xoffset, position.y, color)
		if t > .3 then return false end
	end
end

local Drink = Action:extend()
Drink.name = "drink"
Drink.targets = {targets.Item}

function Drink:__new(owner, target)
	Action.__new(self, owner, target)
	self.name = "drink"
end

function Drink:perform(level)
	local heal = 5
	local target = self.targetActors[1]
	target.name = "bottle"
	target.color = {.5, .5, .5, 1}
	target:removeComponent(components.Light)
	target:removeComponent(components.Usable)

	self.owner:setHP(self.owner:getHP() + 5)
end

local Potion = Actor:extend()
Potion.name = "potion"
Potion.color = {1, 0, 0, 1}
Potion.emissive = true
Potion.char = "!"
Potion.lightEffect = components.Light.effects.pulse({ 0.3, 0.0, 0.0, 1 }, 3, .5)

Potion.components = {
	components.Light({ 0.1, 0.0, 0.0, 1}, 3, Potion.lightEffect),
	components.Item(),
	components.Usable{Drink},
	components.Stats
	{
		STR = 0,
		DEX = 0,
		INT = 0,
		CON = 0,
		maxHP = 1,
		AC = 5
	}
}

return Potion
