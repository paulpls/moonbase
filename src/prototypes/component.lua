--[[

    Component prototype

]]



local M = {}
M.__index = M
M.__name = "Component"



--  Init
function M.new(name, data)
    local new = setmetatable({}, M)
    new.__name = name and table.concat{ name, M.__name } or table.concat{ M.__name, "Prototype" }
    new.id = name

    local data = data or {}

    for k, v in pairs(data) do
        new[k] = v
    end

    return new
end



return M
