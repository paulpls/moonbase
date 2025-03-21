--[[

    System prototype

]]



local M = {}
M.__index = M
M.__name = "System"



function M.match(self, entity)
    if not entity then return false end
    if not entity.components then return false end
    if not next(entity.components) then return false end

    for _, component in pairs(self.components) do
        if not entity:has(component) then return false end
    end

    return true
end



function M.kill(self, entity)
end



function M.load(self, entity)
end



function M.update(self, dt, entity)
end



function M.draw(self, entity)
end



--  Init
function M.new(name, components, data)
    local new = setmetatable({}, M)
    new.__name = name and table.concat{ name, M.__name } or table.concat{ M.__name, "Prototype" }
    new.id = name

    assert(components, table.concat{ "new() arg (2) for ", tostring(new), " expects a list of components, got nil" })
    new.components = components

    local data = data or {}
    new.kill = data.kill or M.kill
    new.load = data.load or M.load
    new.update = data.update or M.update
    new.draw = data.draw or M.draw

    --  Avoid re-copying basic functions when copying data
    data.kill = nil
    data.load = nil
    data.update = nil
    data.draw = nil

    for k, v in pairs(data) do
        new[k] = v
    end

    return new
end




return M
