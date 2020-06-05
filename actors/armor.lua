local Actor = require "actor"

local Armor = Actor:extend()
Armor.char = "["
Armor.name = "armor"

Armor.components = {
	components.Item(),
	components.Equipment{
		slot = "armor",
		effects = {
			conditions.Modifystats{
				AC = 4
			}
		}
	}
}

return Armor
