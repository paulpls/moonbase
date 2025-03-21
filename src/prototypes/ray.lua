--[[

    Ray prototype

]]



local M = {}
M.__index = M
M.__name = "Ray"



function M.new(data)
    local new = setmetatable({}, M)

    local data = data or {}
    new.x = data.x or 0
    new.y = data.y or 0
    new.angle = data.angle or 0
    new.hits = {}
    
    return new
end



return M
