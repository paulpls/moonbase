--[[

    Vector2 prototype

]]



local pow = math.pow
local floor = math.floor
local ceil = math.ceil
local max = math.max
local abs = math.abs



local M = {}
M.__index = M
M.__name = "Vector2"



function M.__tostring(t)
    return table.concat{ "(", tostring(t.x), ", ", tostring(t.y), ")" }
end



--  Adds vectors
function M.__add(t, v)
    return M.new(
        t.x + v.x,
        t.y + v.y
    )
end



--  Subtracts vectors
function M.__sub(t, v)
    return M.new(
        t.x - v.x,
        t.y - v.y
    )
end



--  Multiplies vectors
function M.__mul(t, v)
    local v = type(v) == "table" and v or M.new(v)

    return M.new(
        t.x * v.x,
        t.y * v.y
    )
end



--  Divides vectors
function M.__div(t, v)
    local v = type(v) == "table" and v or M.new(v)

    return M.new(
        t.x / v.x,
        t.y / v.y
    )
end



--  Checks vectors for equality
function M.__eq(t, v)
    return t.x == v.x and t.y == v.y
end



--  Rounds vector values down
function M.floor(self)
    local x = floor(self.x)
    local y = floor(self.y)
    
    return M.new(x, y)
end



--  Rounds vector values up
function M.ceil(self)
    local x = ceil(self.x)
    local y = ceil(self.y)
    
    return M.new(x, y)
end



--  Truncates vector values to the specified number of decimal places
function M.truncate(self, n)
    local n = pow(10, n or 0)
    local x = floor(self.x * n) / n
    local y = floor(self.y * n) / n
    
    return M.new(x, y)
end



--  Sets vector components to zero
function M.zero(self)
    self.x = 0
    self.y = 0
end



--  Returns vector with values coerced to -1, 0, or 1 depending on sign
function M.signum(self)
    local x,y = self:unpack()
    x = x == 0 and 0 or abs(x) / x
    y = y == 0 and 0 or abs(y) / y
    
    return M.new(x, y)
end



--  Copies vector values (avoids modifying upvalues when passing tables as arguments)
function M.copy(self)
    return M.new(
        self.x,
        self.y
    )
end



--  Returns the unit vector
function M.unit(self)
    if self.x == 0 and self.y == 0 then return self end

    local magnitude = pow(pow(self.x, 2) + pow(self.y, 2), 0.5)

    return M.new(self.x/magnitude, self.y/magnitude)
end



--  Returns the vector with values normalized to -1..1
function M.normalize(self)
    if self.x == 0 and self.y == 0 then return self end

    local magnitude = max(abs(self.x), abs(self.y))

    return M.new(self.x/magnitude, self.y/magnitude)
end



--  Returns the vector components as individual values
function M.unpack(self)
    return self.x, self.y
end



--  Init
function M.new(x, y)
    local new = setmetatable({}, M)

    new.x = x or 0
    new.y = y or new.x

    return new
end



return M
