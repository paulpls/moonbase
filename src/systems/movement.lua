--[[

    Movement system

]]



local System = require "src.prototypes.system"
local Vec2 = require "src.prototypes.vec2"
local sin = math.sin
local cos = math.cos
local phys = love.physics



local TAU = math.pi * 2



local M = {}
M.__index = M
M.__name = "Movement"



M.components = {
    "Body",
    "Movement",
}



function M.update(self, dt, entity)
    if entity:has("FixedPosition") then return end

    local movement = entity:get("Movement")
    if not movement.direction then return end

    local body = entity:get("Body")
    local physics = entity:get("Physics")
    local collision = entity:get("Collision")
    local rotation = entity:get("Rotation")

    local speed = movement.speed * dt
    local direction

    if rotation then
        local angle = (rotation.angle + movement.direction) % TAU
        direction = Vec2.new(cos(angle), sin(angle))
    else
        direction = Vec2.new(cos(movement.direction), sin(movement.direction))
    end

    local delta = direction * speed

    if physics and physics.body then
        if physics.body:isBullet() then
            physics.body:setLinearVelocity(delta.x, delta.y)
        else
            local meter = phys.getMeter() / 2
            physics.body:setLinearVelocity(delta.x * meter, delta.y * meter)
        end
    else
        body.position = body.position + delta
    end

    movement.direction = nil
end



function M.new(data)
    local data = data or {}

    data.update = data.update or M.update

    return System.new(M.__name, M.components, data)
end



return M
