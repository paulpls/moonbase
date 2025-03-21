--[[

    World map

]]



local Palette = require "src.palette"
local Vec2 = require "src.prototypes.vec2"
local floor = math.floor
local max = math.max
local pow = math.pow
local gfx = love.graphics



local TAU = 2 * math.pi



local M = {}
M.__index = M
M.__name = "Map"



--  Update map proportions and zoom state
function M.update(self, dt)
    local W,H = gfx.getDimensions()
    local camW,camH = self.cameraDimensions:unpack()
    local mapW,mapH = self.dimensions:unpack()
    local size = self.isZoomed and self.sizeZoomed or self.size
    self.w = floor(camW * size)
    self.h = floor(camH * size)

    if self.isZoomed then
        self.margin = Vec2.new(
            floor((mapW - self.w) / 2),
            floor((mapH - self.h) / 2)
        )
        self.x = floor(W / 2) - floor(self.w / 2)
        self.y = floor(H / 2) - floor(self.h / 2)
    else
        self.margin = Vec2.new(max(
            floor(self.w / 8),
            floor(self.h / 8)
        ))
        self.x = self.margin.x
        self.y = H - self.h - self.margin.y
    end
end



--  TODO Tidy up this method, split into separate methods
local function drawCanvas(self)
    local camera = self.world:getCamera()
    if not camera then return end

    local colliderLineWidth = 2
    local colliderColor = "white"
    local cameraColor = "green"

    local camBody = camera:get("Body")
    local camRotation = camera:get("Rotation")

    local camX,camY = camBody.position:unpack()
    local alpha = self.isZoomed and self.alphaZoomed or self.alpha
    local mapScale = self.isZoomed and self.scaleZoomed or self.scale
    local size = self.tileSize * mapScale
    local r = self.isRelative and (self.fixedAngle - camRotation.angle) % TAU or 0

    --  Draw to the auxilliary map canvas so it can be rotated and scaled
    local oldCanvas = gfx.getCanvas()
    gfx.setCanvas(self.auxCanvas)
    gfx.clear()

    local cw,ch = self.auxCanvas:getDimensions()
    cxCanvas,cyCanvas = floor(cw / 2), floor(ch / 2)

    for y, row in pairs(self.world.grid) do
        for x, entity in pairs(row) do
            local x = (camX - x) * size
            local y = (camY - y) * size

            x = cxCanvas - x
            y = cyCanvas - y

            local highlight = entity:get("Highlight")
            local color = entity:get("Color")
            local _color = highlight and highlight.color or color and color.normal or "none"

            --  Draw entity on map
            Palette.set(_color, { a = alpha })
            gfx.rectangle("fill", x, y, size, size)

            --  Draw entity outline
            Palette.set("black", { a = alpha })
            gfx.rectangle("line", x, y, size, size)

            --  Draw physics
            local physics = entity:get("Physics")

            if physics and self.renderPhysics then
                local body = physics.body
                local shape = physics.shape

                if shape:getType() ~= "circle" then
                    local points = { body:getWorldPoints(shape:getPoints()) }

                    --  Get point position relative to camera position
                    for i = 1, #points, 2 do
                        local x,y = i, i + 1
                        points[x] = cxCanvas - (camX - points[x]) * size
                        points[y] = cyCanvas - (camY - points[y]) * size
                    end

                    Palette.set(colliderColor)
                    gfx.setLineWidth(colliderLineWidth)
                    gfx.polygon("line", unpack(points))
                    gfx.setLineWidth(1)

                else
                    local radius = shape:getRadius() * size
                    local px,py = body:getPosition()
                    px = cxCanvas - (camX - px) * size
                    py = cyCanvas - (camY - py) * size

                    Palette.set(colliderColor)
                    gfx.setLineWidth(colliderLineWidth)
                    gfx.circle("fill", px, py, radius)
                    gfx.setLineWidth(1)
                end
            end
        end
    end

    Palette.set("none")

    --  Draw the aux canvas to the main map canvas
    gfx.setCanvas(self.mapCanvas)
    gfx.clear(Palette.get(self.backgroundColor))

    local W,H = self.mapCanvas:getDimensions()
    cx,cy = floor(W / 2), floor(H / 2)

    gfx.draw(self.auxCanvas, cx, cy, r, mapScale, mapScale, cxCanvas, cyCanvas)

    --  Draw camera at center of map
    Palette.set(cameraColor)

    local icon = camera:get("Icon")

    if icon then
        --  Scale and rotate the icon according to scaled tile size and camera rotation
        local r = self.isRelative and 0 or (camRotation.angle - self.fixedAngle) % TAU
        local w,h = icon.image:getDimensions()
        local avg = (w + h) / 2
        local scale = pow(size / avg, 2)
        local ox,oy = floor(w / 2), floor(h / 2)
        gfx.draw(icon.image, cx, cy, r, scale, scale, ox, oy)
    else
        gfx.circle("fill", cx, cy, floor(size / 4))
    end

    --  Camera collider
    --  NOTE This assumed to be a circular shape with its position fixed to the center of the map
    local camPhysics = camera:get("Physics")

    if camPhysics and self.renderPhysics then
        local shape = camPhysics.shape
        local radius = shape:getRadius() * size * mapScale

        Palette.set(colliderColor)
        gfx.setLineWidth(colliderLineWidth)
        gfx.circle("line", cx, cy, radius)
        gfx.setLineWidth(1)
    end

    Palette.set("none")
    gfx.setCanvas(oldCanvas)
end



--  Draws the map canvas to the screen
function M.draw(self)
    local w = self.w
    local h = self.h
    local x = self.x
    local y = self.y
    local size = self.isZoomed and self.sizeZoomed or self.size
    local alpha = self.isZoomed and self.alphaZoomed or self.alpha

    drawCanvas(self)

    Palette.set("none", { a = alpha })
    gfx.draw(self.mapCanvas, x, y, 0, size, size)

    Palette.set("none")
    gfx.rectangle("line", x, y, w, h)
end



function M.new(data)
    local new = setmetatable({}, M)

    local data = data or {}
    new.world = data.world
    new.dimensions = data.dimensions or Vec2.new(gfx.getDimensions())
    new.cameraDimensions = data.cameraDimensions or Vec2.new(gfx.getDimensions())
    new.backgroundColor = data.backgroundColor or "black"
    new.tileSize = data.tileSize or 16

    --  Canvasses for main map rendering
    new.mapCanvas = gfx.newCanvas(new.cameraDimensions:unpack())
    new.auxCanvas = gfx.newCanvas(new.dimensions:unpack())

    --  Relative: camera rotation is fixed (map rotates)
    --  Absolute: map rotation is fixed (camera rotates)
    new.isRelative = data.isRelative ~= false

    --  Render physics colliders
    new.renderPhysics = data.renderPhysics or false

    --  Fixed angle for relative map
    new.fixedAngle = data.fixedAngle or 3 * TAU / 4

    --  Map zoom
    new.isZoomed = data.isZoomed or false

    --  Normal scale, size, and transparency
    new.size = data.size or 0.25
    new.scale = data.scale or 1
    new.alpha = data.alpha or 1

    --  Zoomed scale, size, and transparency
    new.sizeZoomed = data.sizeZoomed or 1
    new.scaleZoomed = data.scaleZoomed or 1
    new.alphaZoomed = data.alphaZoomed or 0.95

    --  Map proportions, calculated on `update()`
    new.x = data.x or 0
    new.y = data.y or 0
    new.w = data.w or 0
    new.h = data.h or 0
    new.margin = data.margin or Vec2.new()

    return new
end



return M
