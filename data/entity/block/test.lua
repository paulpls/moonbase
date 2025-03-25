--[[

    Test block data

]]



local Vec2 = require "src.prototypes.vec2"
local Texture = require "src.prototypes.texture"



local M = {}



M.components = {
    Body = {
        position = Vec2.new(),
    },
    Color = {
        normal = "gray3",
    },
    Texture = {
        default = Texture.new{ name = "test6" },
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
