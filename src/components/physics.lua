--[[

    Physics component

]]



local Component = require "src.prototypes.component"



local M = {}
M.__index = M
M.__name = "Physics"



local function clamp(n, min, max)
    return n < min and min or (n > max and max or n)
end



function M.new(data)
    local data = data or {}

    data.body = data.body
    data.shape = data.shape
    data.fixture = data.fixure
    data.dimensions = data.dimensions
    data.state = data.state or "static"
    data.restitution = data.restitution
    data.mass = data.mass or 1
    data.linearDamping = data.linearDamping and clamp(data.linearDamping, 0, 1) or 0
    data.isBullet = data.isBullet or false
    data.isSensor = data.isSensor or false
    data.canRotate = data.canRotate or false
    data.angle = data.angle or 0

    return Component.new(M.__name, data)
end



return M
