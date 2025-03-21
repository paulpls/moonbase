--[[

    Highlight component

]]



local Component = require "src.prototypes.component"



local M = {}
M.__index = M
M.__name = "Highlight"



function M.new(data)
    local data = data or {}

    data.color = data.color or "gray1"

    return Component.new(M.__name, data)
end



return M
