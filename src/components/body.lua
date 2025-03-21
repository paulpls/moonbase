--[[

    Body component

]]



local Component = require "src.prototypes.component"
local Vec2 = require "src.prototypes.vec2"



local M = {}
M.__index = M
M.__name = "Body"



function M.new(data)
    local data = data or {}

    data.position = data.position or Vec2.new()
    data.dimensions = data.dimensions or Vec2.new(1)
    data.offset = data.offset or Vec2.new()

    return Component.new(M.__name, data)
end



return M
