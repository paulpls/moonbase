--[[

    Skybox

]]



local floor = math.floor
local max = math.max
local gfx = love.graphics



local TAU = 2 * math.pi



local M = {}
M.__index = M
M.__name = "Skybox"



function M.load(self)
    for id, layer in ipairs(self.layers) do

        if not layer.image then
            layer.image = gfx.newImage(layer.path)
        end
    end
end



local function drawToCanvas(self, th)
    local th = th or 0

    local oldCanvas = gfx.getCanvas()
    gfx.setCanvas(self.canvas)
    gfx.clear()

    for id, layer in ipairs(self.layers) do
        local w,h = layer.image:getDimensions()
        local x = floor(w * th / TAU)

        gfx.draw(layer.image, 0 - x, 0)

        if layer.doRepeat and w - x < self.canvas:getWidth() then
            gfx.draw(layer.image, w - x - 1, 0)
        end
    end

    gfx.setCanvas(oldCanvas)
end



--  Scale, recenter, and draw the skybox
function M.draw(self, th, scale)
    drawToCanvas(self, th)

    local W,H = self.canvas:getDimensions()

    local scale = scale or 1
    scale = max(1, scale * self.scaleFactor)

    local w,h = floor(W * scale), floor(H * scale)
    local x = floor((w - W) / -2)
    local y = floor((h - H) / -1)

    gfx.draw(self.canvas, x, y, 0, scale, scale)
end



function M.new(data)
    local new = setmetatable({}, M)

    local data = data or {}
    new.scaleFactor = data.scaleFactor or 0.5
    new.canvas = data.canvas or gfx.newCanvas()
    new.layers = data.layers or {
        [1] = {
            path = "res/skybox/default.png",
            doRepeat = true,
        },
    }

    new:load()

    return new
end



return M
