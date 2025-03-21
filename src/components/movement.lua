--[[

    Movement component

]]



local Component = require "src.prototypes.component"
local Vec2 = require "src.prototypes.vec2"



local M = {}
M.__index = M
M.__name = "Movement"



function M.new(data)
    local data = data or {}

    data.speed = data.speed or 1
    data.delta = data.delta or Vec2.new()

    return Component.new(M.__name, data)
end



return M
