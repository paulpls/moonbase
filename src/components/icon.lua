--[[

    Icon component

]]



local Component = require "src.prototypes.component"



local M = {}
M.__index = M
M.__name = "Icon"



function M.new(data)
    local data = data or {}

    data.path = data.path or "res/icon/"
    data.name = data.name or "default"

    return Component.new(M.__name, data)
end



return M
