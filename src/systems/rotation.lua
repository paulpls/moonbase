--[[

    Rotation system

]]



local System = require "src.prototypes.system"
local Vec2 = require "src.prototypes.vec2"
local sin = math.sin
local cos = math.cos



local TAU = math.pi * 2



local M = {}
M.__index = M
M.__name = "Rotation"



M.components = {
    "Rotation",
}



function M.update(self, dt, entity)
    local rotation = entity:get("Rotation")
    if rotation.delta == 0 then return end

    --  Make speed slower when field of vision is narower
    local camera = entity.world:getCamera():get("Camera")
    local speedMod = camera.fov / camera.fovMax

    local delta = rotation.delta * rotation.speed * speedMod * dt
    rotation.angle = (rotation.angle + delta) % TAU

    rotation.direction = Vec2.new(
        cos(rotation.angle),
        sin(rotation.angle)
    )

    rotation.delta = 0
end



function M.new(data)
    local data = data or {}

    data.update = data.update or M.update

    return System.new(M.__name, M.components, data)
end



return M
