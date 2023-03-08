local Object = require "object"

local function hash(x, y)
    return x and y * 0x4000000 + x or false --  26-bit x and y
end

local function unhash(hash)
    return hash % 0x4000000, math.floor(hash / 0x4000000)
end

local dummy = {}
local SparseMap = Object:extend()

function SparseMap:__new()
    self.map = {}
end

function SparseMap:get(x, y)
    return self.map[hash(x, y)] or dummy
end

function SparseMap:getByHash(hash)
    return self.map[hash] or dummy
end

function SparseMap:each()
    local k, v = next(self.map, nil)
    local i, j

    return function ()
        if k then
            i, j = next(v, i)
            if i then
                local x, y = unhash(k)
                return x, y, i
            else
                k, v = next(self.map, k)

                if k then
                    i, j = next(v, i)
                    local x, y = unhash(k)
                    return x, y, i
                end
            end
        end  
    end
end

-- This shouldn't be called often as it's going to be relatively expensive.
function SparseMap:count()
    local count = 0

    for _, v in pairs(self.map) do
        for _, _ in pairs(v) do
            count = count + 1
        end
    end

    return count
end

function SparseMap:countCell(x, y)
    local count = 0

    for _, _ in pairs(self.map[hash(x, y)] or dummy) do
        count = count + 1
    end

    return count
end

function SparseMap:has(x, y, value)
    if not self.map[hash(x, y)] then return false end
    return self.map[hash(x, y)][value] or false
end

function SparseMap:insert(x, y, val)
    if not self.map[hash(x, y)] then self.map[hash(x, y)] = {} end

    self.map[hash(x, y)][val] = true
end

function SparseMap:remove(x, y, val)
    if not self.map[hash(x, y)] then return false end
    self.map[hash(x, y)][val] = nil
    return true
end

local test = SparseMap()
test:insert(1, 1, "test")
test:insert(1, 1, "test2")
test:insert(1, 1, "test3")

assert(test:count() == 3)
assert(test:countCell(1, 1) == 3)
assert(test:has(1, 1, "test"))
assert(test:has(1, 1, "test2"))
assert(test:has(1, 1, "test3"))
assert(test:get(1, 1).test)
assert(test:get(1, 1).test2)
assert(test:get(1, 1).test3)
assert(not test:has(1, 1, "test4"))
assert(test:remove(1, 1, "test"))
assert(test:count() == 2)
return SparseMap