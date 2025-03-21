--[[

    Default block data

]]



local Vec2 = require "src.prototypes.vec2"



local M = {}



M.components = {
    Body = {
        position = Vec2.new(),
    },
    Color = {
        normal = "gray1",
    },
    Texture = {
        default = "default",
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
