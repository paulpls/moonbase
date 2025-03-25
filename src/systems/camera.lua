--[[

    Camera system
    TODO Tidy up this file, maybe split into different systems

]]



local System = require "src.prototypes.system"
local Vec2 = require "src.prototypes.vec2"
local Ray = require "src.prototypes.ray"
local Palette = require "src.palette"
local floor = math.floor
local sin = math.sin
local cos = math.cos
local abs = math.abs
local min = math.min
local gfx = love.graphics



local TAU = math.pi * 2



local M = {}
M.__index = M
M.__name = "Camera"



M.components = {
    "Body",
    "Rotation",
    "Camera",
}



function M.load(self, entity)
    local camera = entity:get("Camera")

    --  Create camera canvas
    local W,H = entity.world.cameraDimensions:unpack()
    camera.canvas = gfx.newCanvas(W, H)

    --  Calculate line height based on ratio of canvas dimensions
    if not camera.lineHeight then
        camera.lineHeight = H / W
    end

    --  Get reticle image
    if camera.reticlePath then
        camera.reticle = gfx.newImage(camera.reticlePath)
    end

    --  Get scope image
    if camera.scopePath then
        camera.scope = gfx.newImage(camera.scopePath)
    end
end



local function getObject(world, ray, camX, camY, camAngle, gridX, gridY, distance, unitDistance, direction, side)
    if not world.grid[gridY] then return end

    local entity = world.grid[gridY][gridX]
    if not entity then return end

    if not entity:has("Render") then return end

    local hit = {
        entity = entity,
        angle = ray.angle,
        angleOffset = (camAngle - ray.angle) % TAU,
        side = side,
        gridX = gridX,
        gridY = gridY,
    }

    --  Depending on which side was hit, define distance and intercept
    if hit.side == 0 then
        hit.distance = distance.x - unitDistance.x
        hit.intercept = camY + hit.distance * direction.y
    else
        hit.distance = distance.y - unitDistance.y
        hit.intercept = camX + hit.distance * direction.x
    end

    --  Reverse textures where necessary
    local revX = hit.side == 0 and cos(hit.angle) < 0  --  East-facing side (camera facing west)
    local revY = hit.side == 1 and sin(hit.angle) > 0  --  North-facing side (camera facing south)
    hit.isReversed = revX or revY

    hit.intercept = hit.intercept - floor(hit.intercept)

    --  Stop here if the object is not transparent, as the opposite side is invisible
    if not hit.entity:has("Transparency") then
        return hit
    end

    local inside = {
        entity = entity,
        angle = ray.angle,
        angleOffset = (camAngle - ray.angle) % TAU,
        inside = true,
        gridX = gridX,
        gridY = gridY,
    }

    --  Calculate on which side the inside face was hit
    if hit.side == 0 then
        inside.side = distance.x <= distance.y and 0 or 1
    else
        inside.side = distance.y <= distance.x and 1 or 0
    end

    --  For the opposite side, the wall is hit at `2 * distance.x` or `distance.y`,
    --  whichever is closer. Swap x and y where needed. A tiny bit is removed from
    --  distance so inner faces and adjacent outer faces aren't competing for space
    --  when projected onto the screen.
    local tinyBit = 0.00001

    --  Calculate distance to inside face
    if inside.side == 0 then
        inside.distance = min(distance.x, distance.y * 2) - tinyBit
        inside.intercept = camY + inside.distance * direction.y
    else
        inside.distance = min(distance.x * 2, distance.y) - tinyBit
        inside.intercept = camX + inside.distance * direction.x
    end

    inside.intercept = inside.intercept - floor(inside.intercept)

    --  Evaluate textures
    local texture = entity:get("Texture")

    --  Stop here if no textures found
    if not texture then
        return hit, inside
    end

    --  Reverse textures where necessary for inside faces
    if texture.inside then
        local revX = inside.side == 0 and cos(hit.angle) < 0  --  Inner west-facing side
        local revY = inside.side == 1 and sin(hit.angle) > 0  --  Inner north-facing side
        inside.isReversed = revX or revY
    else
        --  If using the outside texture, flip the opposite faces
        local revX = inside.side == 0 and cos(hit.angle) > 0  --  Inner east-facing side
        local revY = inside.side == 1 and sin(hit.angle) < 0  --  Inner south-facing side
        inside.isReversed = revX or revY
    end

    return hit, inside
end



local function dda(ray, entity)
    local world = entity.world
    if not world or not world.grid then return end

    local body = entity:get("Body")
    local rotation = entity:get("Rotation")
    local camera = entity:get("Camera")

    local W,H = camera.canvas:getDimensions()
    local camX,camY = body.position:unpack()
    local gridX,gridY = body.position:floor():unpack()

    --  Get ray direction vector
    local direction = Vec2.new(
        cos(ray.angle),
        sin(ray.angle)
    )
    --  Initialize distance to nearest grid tile, depending on facing
    local initDistance = Vec2.new(
        direction.x < 0 and camX - gridX or 1 + gridX - camX,
        direction.y < 0 and camY - gridY or 1 + gridY - camY
    )
    --  Unit distance
    local unitDistance = Vec2.new(
        1 / abs(direction.x),
        1 / abs(direction.y)
    )
    local distance = initDistance * unitDistance
    local step = direction:signum()
    local side

    --  Perform DDA and register hits
    while min(distance:unpack()) <= camera.viewDistance do
        if distance.x < distance.y then
            distance.x = distance.x + unitDistance.x
            gridX = gridX + step.x
            side = 0
        else
            distance.y = distance.y + unitDistance.y
            gridY = gridY + step.y
            side = 1
        end

        local hit, inside = getObject(world, ray, camX, camY, rotation.angle, gridX, gridY, distance, unitDistance, direction, side)

        if hit then
            table.insert(ray.hits, hit)
        end

        if inside then
            table.insert(ray.hits, inside)
        end
    end

    --  Stop here if nothing was hit
    if not next(ray.hits) then return end

    --  Evaluate hits, calculate distance and intercept
    for id, hit in ipairs(ray.hits) do
        --  Multiplying the ray's distance by the cosine of the
        --  difference in angle from the the camera to the ray
        --  will give a corrected distance to the camera plane,
        --  avoiding the fisheye effect.
        hit.distance = hit.distance * cos(hit.angleOffset)

        local h = floor(H / hit.distance)

        --  Projected line properties for rendering
        local lineHeight = camera.lineHeight
        local lineScale = (lineHeight / (camera.fov / camera.fovMax))
        local zoom = 1 - lineScale
        local yo = floor(zoom * H - H / 2)
        local alpha = 1

        --  Apply fog of void based on actual distance (no fisheye correction)
        local actualDistance = hit.distance / cos(hit.angleOffset)

        if actualDistance > camera.viewDistance - camera.fogDistance then
            local delta = actualDistance - (camera.viewDistance - camera.fogDistance)
            alpha = (camera.fogDistance - delta) / camera.fogDistance
        end

        --  Define projected line attributes
        hit.line = {
            start = floor((H - h * lineHeight) * lineScale) + yo,
            stop = floor((H + h * lineHeight) * lineScale) + yo,
            alpha = alpha
        }
    end

    table.sort(ray.hits, function(a, b) return a.distance < b.distance end)

    return ray.hits
end



--  Initialize raycasting
local function initRaycast(entity)
    local body = entity:get("Body")
    local rotation = entity:get("Rotation")
    local camera = entity:get("Camera")

    --  Get width of camera canvas with resolution applied
    local W = floor(camera.resolution * camera.canvas:getWidth())

    --  Set up raycasting
    camera.rays = {}

    for n = 1, W do
        --  Normalize the screen X coordinate's distance from center
        --  to (-0.5...0.5) and use it to offset the angle of the ray
        --  within the field of view relative to the camera's direction
        local offset = (n - 1) / W - 0.5
        local th = camera.fov * offset

        local rayData = {
            x = body.position.x,
            y = body.position.y,
            angle = (rotation.angle + th) % TAU,
        }

        camera.rays[n] = Ray.new(rayData)
    end
end



--  Evaluate raycasting
local function evaluateRaycast(entity)
    local body = entity:get("Body")
    local rotation = entity:get("Rotation")
    local camera = entity:get("Camera")

    --  Stop here if no rays to evaluate
    if not next(camera.rays) then return end

    local W,H = camera.canvas:getDimensions()

    --  Perform DDA for each ray
    for x, ray in ipairs(camera.rays) do
        dda(ray, entity)
    end
end



local function raycast(entity)
    initRaycast(entity)
    evaluateRaycast(entity)
end



function M.update(self, dt, entity)
    local camera = entity:get("Camera")
    if not camera.isActive then return end

    raycast(entity)
end



--  Returns the appropriate side face to use for texture rendering.
--  TODO Add functionality to handle block rotation; for now all
--  blocks are assumed to have their front sides facing north.
local function getFace(hit)
    local face = "front"

    if hit.side == 0 then
        face = cos(hit.angle) < 0 and "left" or "right"
    else
        face = sin(hit.angle) < 0 and "back" or "front"
    end

    return face
end



--  Draws the projection of the raycast on the screen, with textures
local function drawProjectionTextured(x, hit, camera)
    --  Skip projection if no line found during raycast, or if the
    --  hit object's textures are missing
    if not hit.line then return end

    --  Get texture information
    local texture = hit.entity:get("Texture")
    local _texture

    if hit.inside then 
         _texture = texture.inside
    end

    _texture = _texture or texture.default

    --  Stop rendering if no texture is registered
    if not _texture then return end

    --  Texture dimensions
    local tw,th = _texture.size, _texture.size

    --  Ray intercept point as a proportion of texture width
    local intercept = floor(hit.intercept * tw)

    --  Detect which side face was hit
    local face = getFace(hit)

    --  Projected line properties
    local W,H = camera.canvas:getDimensions()
    local resolution = W * camera.resolution
    local w = floor(W / resolution)
    local h = (hit.line.stop - hit.line.start) / th
    local x = (x - 1) * w
    local y = hit.line.start
    local alpha = hit.line.alpha

    --  Reverse textures where necessary
    local intercept = hit.isReversed and tw - intercept - 1 or intercept

    --  Get highlight and color data, and add shading to one side of the entity
    local highlight = hit.entity:get("Highlight")
    local color = highlight and highlight.color or "none"
    local shade = hit.side == 0 and camera.normalColor or camera.shadeColor
    color = Palette.shade(color, shade, alpha)
    gfx.setColor(color)

    --  Draw the appropriate slice of the texture
    local image = _texture.image
    local quad = _texture:getColumn(face, intercept)
    gfx.draw(image, quad, x, y, 0, w, h)

    Palette.set("none")
end



--  Draws the projection of the raycast on the screen, without textures
local function drawProjection(x, hit, camera)
    --  Skip projection if no line found during raycast, or if the
    --  hit object's textures are missing
    if not hit.line then return end

    --  Projected line properties
    local W,H = camera.canvas:getDimensions()
    local resolution = W * camera.resolution
    local w = floor(W / resolution)
    local h = hit.line.stop - hit.line.start
    local x = (x - 1) * w
    local y = hit.line.start
    local alpha = hit.line.alpha

    --  Get color and highlight information
    local color = hit.entity:get("Color") or {}
    color = {
        normal = color.normal or camera.normalColor,
        shade = color.shade or camera.shadeColor,
    }

    local highlight = hit.entity:get("Highlight")
    highlight = highlight and highlight.color or color.normal

    --  Add shading to one side of the entity
    local lineColor = hit.side == 0 and "none" or color.shade
    lineColor = Palette.shade(highlight, lineColor, alpha)

    gfx.setColor(lineColor)

    --  Draw the projected line
    gfx.rectangle("fill", x, y, w, h)

    Palette.set("none")
end



--  Returns a list of objects the ray has hit for rendering
--  Stops at first opaque object
local function getRenderableHits(ray)
    if not ray.hits or not next(ray.hits) then return {} end

    local hits = {}

    local n = 1

    while n <= #ray.hits do
        local hit = ray.hits[n]
        table.insert(hits, hit)
        n = n + 1

        if not hit.entity:has("Transparency") then break end
    end

    --  Furthest objects get rendered first
    table.sort(hits, function(a, b) return a.distance > b.distance end)

    return hits
end



--  Draw the raycast projection
local function drawRaycast(camera)
    for x, ray in ipairs(camera.rays) do

        local hits = getRenderableHits(ray)

        for id, hit in ipairs(hits) do
            if hit.entity:has("Texture") and camera.renderTextures then
                drawProjectionTextured(x, hit, camera)
            else
                drawProjection(x, hit, camera)
            end
        end
    end
end



--  Draws the reticle at the center of the canvas
--  TODO Move scaling calculation to `update()` so there is no delay
local function drawReticle(camera, scale)
    if not camera.reticle then return end

    local W,H = camera.canvas:getDimensions()
    local w,h = camera.reticle:getDimensions()
    local scale = scale or camera.reticleScale

    x = floor(W / 2 - w * scale / 2)
    y = floor(H / 2 - h * scale / 2)

    local isZoomed = camera.fov ~= camera.fovMax
    local alpha = isZoomed and 0 or camera.fov / camera.fovMax

    Palette.set("none", { a = alpha })
    gfx.draw(camera.reticle, x, y, 0, scale, scale)

    Palette.set("none")
end



--  Draw the scope at the center of the canvas
--  TODO Move scaling calculation to `update()` so there is no delay
local function drawScope(camera, scale)
    if not camera.scope then return end

    local W,H = camera.canvas:getDimensions()
    local w,h = camera.scope:getDimensions()
    local scale = scale or camera.scopeScale

    x = floor(W / 2) - floor(w * scale / 2)
    y = floor(H / 2) - floor(h * scale / 2)

    local isZoomed = camera.fov ~= camera.fovMax
    local alpha = isZoomed and 1 - (camera.fov - camera.fovMin) / camera.fovMax or 0

    Palette.set("none", { a = alpha })
    gfx.draw(camera.scope, x, y, 0, scale, scale)

    Palette.set("none")
end



--  Draw to the the camera canvas
function M.draw(self, entity)
    local camera = entity:get("Camera")
    if not camera.isActive then return end


    local oldCanvas = gfx.getCanvas()
    gfx.setCanvas(camera.canvas)
    gfx.clear()

    entity.world:drawSkybox()
    entity.world:drawFloor()
    drawRaycast(camera)
    drawReticle(camera)
    drawScope(camera)

    gfx.setCanvas(oldCanvas)
end



function M.new(data)
    local data = data or {}

    data.load = data.load or M.load
    data.update = data.update or M.update
    data.draw = data.draw or M.draw

    return System.new(M.__name, M.components, data)
end



return M
