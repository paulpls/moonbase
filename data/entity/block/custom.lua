--[[

    Custom behavior block data, for sensors and such

]]



local Vec2 = require "src.prototypes.vec2"



local M = {}



M.components = {
    Body = {
        position = Vec2.new(),
    },
    Color = {
        normal = "transparent",
    },
    Physics = {
        state = "static",
        mass = 0,
        isSensor = true,
    },
    Collision = {
        classList = { "Custom" },
        handlers = {
            Camera = {
                beginContact = require("src.behaviors.notifyCollision"),
            },
        },
    },
}



return M
