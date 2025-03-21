--[[

    Hazard block data

]]



local Vec2 = require "src.prototypes.vec2"



local M = {}



M.components = {
    Body = {
        position = Vec2.new(),
    },
    Color = {
        normal = "yellow",
    },
    Texture = {
        default = "hazard",
    },
    Render = {},
    Physics = {
        state = "static",
    },
    Collision = {
        classList = { "Block" },
    },
}



return M
