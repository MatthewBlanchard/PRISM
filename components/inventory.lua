local Component = require "component"

local Inventory = Component:extend()
Inventory.name = "Inventory"

Inventory.requirements = {
  components.Stats
}

Inventory.actions = {
  actions.Drop,
  actions.Pickup,
  actions.Throw
}

function Inventory:initialize(actor)
  self.inventory = {}
  
  print("WOWEEE", #self.actions)
end

function Inventory:hasItem(item)
  for k, v in pairs(self.inventory) do
    if v == item then
      return k
    end
  end

  return false
end

function Inventory:hasItemType(item)
  for k, v in pairs(self.inventory) do
    if v:is(item) then
      return k
    end
  end

  return false
end

function Inventory:addItem(item)
  if not Inventory.hasItem(self, item) then
    table.insert(self.inventory, item)
  end
end

function Inventory:removeItem(item)
  for i = 1, #self.inventory do
    if self.inventory[i] == item then
      table.remove(self.inventory, i)
    end
  end
end

function Inventory:removeItemType(item)
  for k, v in pairs(self.inventory) do
    if v:is(item) then
      table.remove(self.inventory, k)
      return
    end
  end
end

return Inventory
