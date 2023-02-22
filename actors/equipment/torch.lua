local Actor = require "actor"
local Tiles = require "tiles"

local Torch = Actor:extend()
Torch.char = Tiles["shortsword"]
Torch.name = "torch"

local lightEffect = components.Light.effects.flicker({ 0.8666, 0.4509, 0.0862, 1 }, 0.2, 0.07)

Torch.components = {
    components.Light{
        color = { 0.8666, 0.4509, 0.0862, 1},
        intensity = 4,
        effect = lightEffect
    },
    components.Item(),
    components.Equipment{
        slot = "offhand",
    },
}

return Torch
