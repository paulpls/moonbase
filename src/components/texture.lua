--[[

    Texture component

]]



local Component = require "src.prototypes.component"



local M = {}
M.__index = M
M.__name = "Texture"



function M.new(data)
    local data = data or {}

    data.default = data.default or "default"
    data.inside = data.inside

    return Component.new(M.__name, data)
end



return M
