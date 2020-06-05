local Panel = require "panel"
local ContextPanel = require "panels.context"

local InventoryPanel = Panel:extend()
InventoryPanel.interceptInput = true

local function correctWidth(s, w)
	if string.len(s) < w then
		return s .. string.rep(" ", w - string.len(s))
	elseif string.len(s) > w then
		return string.sub(s, 1, w)
	else
		return s
	end
end

function InventoryPanel:draw()
	local actor = game.curActor

	local w = string.len("Inventory    ")
	self:write("Inventory    ", 1, 1, {1, 1, 1, 1}, {.3, .3, .3, 1})
	if actor.inventory and #actor.inventory > 0 then
		for i = 1, #actor.inventory do
			local bg = {.1, .1, .1, 1}
			if i % 2 == 0 then bg = {.2, .2, .2, 1} end

			local inventoryString = i .. "  " .. actor.inventory[i].name
			inventoryString = correctWidth(inventoryString, w)
			self:write(inventoryString, 1, 1+i, {1, 1, 1, 1}, bg)
		end
	end
end

function InventoryPanel:update(dt)
	if #game.curActor.inventory == 0 then
		game.interface:pop()
	end
end

function InventoryPanel:handleKeyPress(keypress)
	Panel.handleKeyPress(self, keypress)

	local item = game.curActor.inventory[tonumber(keypress)]
	if item then
		game.interface:push(ContextPanel(self.display, self, game.curActor.inventory[tonumber(keypress)]))
	end
end

return InventoryPanel
