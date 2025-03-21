--[[

    Color component

]]



local Component = require "src.prototypes.component"



local M = {}
M.__index = M
M.__name = "Color"



function M.new(data)
    local data = data or {}

    data.normal = data.normal or "none"
    data.shade = data.shade

    return Component.new(M.__name, data)
end



return M
