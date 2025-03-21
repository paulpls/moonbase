--[[

    Collision component

]]



local Component = require "src.prototypes.component"



local M = {}
M.__index = M
M.__name = "Collision"



function M.new(data)
    local data = data or {}
    data.classList = data.classList or {}
    data.classes = data.classes or { [1] = "Default" }
    data.ignoreList = data.ignoreList or {}
    data.ignores = data.ignores or { [1] = "Default" }
    data.handlers = data.handlers or {}

    return Component.new(M.__name, data)
end



return M
