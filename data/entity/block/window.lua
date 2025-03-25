--[[

    Window entity data

]]



local Vec2 = require "src.prototypes.vec2"
local Texture = require "src.prototypes.texture"



local M = {}



M.components = {
    Body = {
        position = Vec2.new(),
    },
    Color = {
        normal = "gray1",
    },
    Texture = {
        default = Texture.new("window"),
        inside = Texture.new("window_inside"),
    },
    Transparency = {},
    Render = {},
    Physics = {
        state = "static",
    },
    Collision = {
        classList = { "Block" },
    },
}



return M
