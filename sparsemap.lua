local Object = require "object"

local function hash(x, y)
    return x and y * 0x4000000 + x or false --  26-bit x and y
end

local dummy = {}
local SparseMap = Object:extend()

function SparseMap:get(x, y)
    return self[hash(x, y)] or dummy
end

function SparseMap:insert(x, y, val)
    if not self[hash(x, y)] then self[hash(x, y)] = {} end

    self[hash(x, y)][val] = true
end

function SparseMap:remove(x, y, val)
    if not self[hash(x, y)] then return end
    self[hash(x, y)][val] = nil
end

return SparseMap