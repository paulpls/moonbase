--[[

    Camera component

]]



local Component = require "src.prototypes.component"
local rad = math.rad



local M = {}
M.__index = M
M.__name = "Camera"



function M.new(data)
    local data = data or {}

    data.isActive = data.isActive and true or false
    data.renderTextures = data.renderTextures ~= false
    data.resolution = data.resolution or 1
    data.viewDistance = data.viewDistance or 50
    data.fogDistance = data.fogDistance or 1
    --  Field of vision
    data.fov = data.fov or rad(66)
    data.fovMin = data.fovMin or rad(10)
    data.fovMax = data.fovMax or rad(66)
    --  Projected line proportions (computed during `CameraSystem:load()` if not set)
    data.lineHeight = data.lineHeight
    --  Zoom
    data.zoomSpeed = data.zoomSpeed or 8
    --  Projection colors
    data.normalColor = data.normalColor or"none"
    data.shadeColor = data.shadeColor or "gray1"
    --  Reticle
    data.reticlePath = data.reticlePath or "res/reticle/default.png"
    data.reticleScale = data.reticleScale or 2
    --  Scope
    data.scopePath = data.scopePath or "res/scope/default.png"
    data.scopeScale = data.scopeScale or 2

    return Component.new(M.__name, data)
end



return M
