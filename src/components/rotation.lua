--[[

    Rotation component

]]



local Component = require "src.prototypes.component"
local Vec2 = require "src.prototypes.vec2"
local sin = math.sin
local cos = math.cos



local TAU = math.pi * 2



local M = {}
M.__index = M
M.__name = "Rotation"



function M.new(data)
    local data = data or {}

    data.angle = data.angle or 0
    data.direction = data.direction or Vec2.new(
        cos(data.angle),
        sin(data.angle)
    )
    data.speed = data.speed or TAU / 2
    data.delta = data.delta or 0

    return Component.new(M.__name, data)
end



return M
