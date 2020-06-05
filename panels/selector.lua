local Panel = require "panel"

function blink(period)
	local t = 0
	return function(dt)
		t = t + dt
		if t < period then
			return true
		elseif t > period*2 then
			t = t - period * 2
			return false
		elseif t > period then
			return false
		end
	end
end

local SelectorPanel = Panel:extend()
SelectorPanel.interceptInput = true

function SelectorPanel:__new(display, parent, action, targets)
	Panel.__new(self, display, parent, 1, 1, display:getWidth(), display:getHeight())
	self.action = action
	self.blinkFunc = blink(0.3)
	print(#targets)
	self.targets = targets or {}
end

function SelectorPanel:draw()
	local target = self.curTarget
	local blinkString = self.blink and target.char or "X"
	local blinkColor = self.blink and target.color or {.6, 0, 0, 1}

	display:write(blinkString, target.position.x, target.position.y, blinkColor)
	display:write(target.name, target.position.x+2, target.position.y)
end

function SelectorPanel:update(dt)
	self.blink = self.blinkFunc(dt)

	if not self.targetIndex then
		self:tabTarget(actor)
	end
end

function SelectorPanel:tabTarget(actor)
	local n = 1
	local currentTarget = #self.targets+1


	if #self:getValidTargets(currentTarget) < 1 then
		game.interface:reset()
		return
	end

	if self.targetIndex then
		if self.targetIndex + 1 > #self:getValidTargets(currentTarget) then
			n = 1
		else
			n = self.targetIndex + 1
		end
	end

	self.targetIndex = n
	self.curTarget = self:getValidTargets(currentTarget)[n]
end

function SelectorPanel:getValidTargets(index)
	local targets = {}

	for i = 1, #game.curActor.seenActors do
		if self.action:validateTarget(index, game.curActor, game.curActor.seenActors[i]) then
			local isTargeted = false

			for j = 1, #self.targets do
				isTargeted = self.targets[j] == game.curActor.seenActors[i]
				if isTargeted then
					break
				end
			end

			if not isTargeted then
				table.insert(targets, game.curActor.seenActors[i])
			end
		end
	end

	return targets
end

function SelectorPanel:handleKeyPress(keypress)
	Panel.handleKeyPress(self, keypress)

	if keypress == "tab" then
		self:tabTarget(self.curActor)
	elseif keypress == "return" then
		table.insert(self.targets, self.curTarget)
		self.targetIndex = nil

		print(#self.targets)
		if #self.targets == self.action:getNumTargets() then
			game.interface:reset()
			game.interface:setAction(self.action(game.curActor, self.targets))
		end
	end
end

return SelectorPanel
