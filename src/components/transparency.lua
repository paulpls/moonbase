--[[

    Transparency component

]]



local Component = require "src.prototypes.component"



local M = {}
M.__index = M
M.__name = "Transparency"



function M.new(data)
    local data = data or {}

    data.alpha = data.alpha or 1

    return Component.new(M.__name, data)
end



return M
