--[[

    Default camera entity data

]]



local Vec2 = require "src.prototypes.vec2"
local phys = love.physics



local M = {}



M.components = {
    Body = {
        dimensions = Vec2.new(0.5),
    },
    Rotation = {},
    Movement = {},
    Camera = {
        viewDistance = 64,
        fogDistance = 8,
    },
    Physics = {
        state = "dynamic",
        linearDamping = 1,
        shape = phys.newCircleShape(1),
    },
    Collision = {
        classList = { "Camera" },
        ignoreList = { "Camera", "Passthrough" },
    },
    Icon = {
        name = "camera",
    }
}



return M
