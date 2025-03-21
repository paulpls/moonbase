--[[

    World

]]



local Palette = require "src.palette"
local Skybox = require "src.skybox"
local Map = require "src.map"
local Vec2 = require "src.prototypes.vec2"
local Entity = require "src.prototypes.entity"
local CameraSystem = require "src.systems.camera"
local RotationSystem = require "src.systems.rotation"
local MovementSystem = require "src.systems.movement"
local PhysicsSystem = require "src.systems.physics"
local IconSystem = require "src.systems.icon"
local floor = math.floor
local min = math.min
local max = math.max
local pow = math.pow
local gfx = love.graphics
local kbd = love.keyboard



local TAU = math.pi * 2



local M = {}
M.__index = M
M.__name = "World"



function M.load(self)
    --  Add a default camera if none is provided
    if not next(self.cameras) then
        self:addCamera()
    end

    --  Register all systems to the world
    self.systems = {}

    for i, system in ipairs(self._systems) do
        self:registerSystem(system)
    end
end



--  Register a system to be used by the world
function M.registerSystem(self, system)
    table.insert(self.systems, system)
end



--  Adds a texture to the cache and breaks it up into columns
function M.registerTexture(self, name)
    local dir = "res/texture/"
    local name = name or "default"
    local ext = ".png"
    local path = table.concat{ dir, name, ext }

    --  Slice the texture into 1px wide columns
    local image = gfx.newImage(path)
    local w,h = image:getDimensions()
    local quads = {}

    for x = 0, w - 1 do
        quads[x] = gfx.newQuad(x, 0, 1, h, image)
    end

    self.textures[name] = {
        image = image,
        quads = quads
    }
end



--  Add a new entity
function M.add(self, entity)
    if not entity then return end

    entity.world = self

    --  Add entities that aren't cameras to the world grid
    local body = entity:get("Body")

    if body and not entity:has("Camera") then
        local x,y = body.position:floor():unpack() 

        if not self.grid[y] then
            self.grid[y] = {}
        end

        self.grid[y][x] = entity
    end

    --  Add entity to world
    table.insert(self.entities, entity)

    return entity
end



--  Kill an entity
function M.kill(self, id)
    local entity = self.entities[id]
    if not entity then return end

    for _, system in ipairs(self.systems) do
        if system:match(entity) then
            system:kill(entity)
        end
    end

    table.remove(self.entities, id)
end



--  Adds a new camera to the world. The new camera's position and
--  rotation will match the currently active camera, if available.
--  NOTE New camera is always active if no cameras are present.
function M.addCamera(self, position, angle, isActive)
    --  Get current camera parameters
    local currentCamera = self:getCamera()
    local body, rotation

    if currentCamera then 
        body = currentCamera:get("Body")
        rotation = currentCamera:get("Rotation")
    end

    --  Configure new camera parameters
    local position = position or (body and body.position:copy() or Vec2.new(10))
    local angle = angle and angle % TAU or (rotation and rotation.angle or TAU * 5 / 8)
    local isActive = not next(self.cameras) and true or isActive

    local components = {
        Body = {
            position = position,
        },
        Rotation = {
            angle = angle,
        },
    }

    local newCamera = Entity.new("camera", "default", components)
    table.insert(self.cameras, newCamera)
    self:add(newCamera)

    local id = #self.cameras

    if isActive then
        self:setCamera(id)
    end
end



--  Returns the camera entity matching the provided id, or the current camera
function M.getCamera(self, id)
    return self.cameras[id or self.camera]
end



--  Set the current camera entity if one with the provided id exists
function M.setCamera(self, id)
    local newCamera = self:getCamera(id)
    if not newCamera then return end

    local oldCamera = self:getCamera()

    if oldCamera then
        oldCamera:get("Camera").isActive = false
    end

    newCamera:get("Camera").isActive = true

    self.camera = id
end



--  Set the current camera to the first camera
function M.selectFirstCamera(self)
    self:setCamera(1)
end



--  Set the current camera to the next camera
function M.selectNextCamera(self)
    local id = min(#self.cameras, self.camera + 1)
    self:setCamera(id)
end



--  Set the current camera to the previous camera
function M.selectPreviousCamera(self)
    local id = max(1, self.camera - 1)
    self:setCamera(id)
end



--  Set the current camera to the last camera
function M.selectLastCamera(self)
    self:setCamera(#self.cameras)
end



--  Returns general world information
function M.getInfo(self)
    return {
        [1] = table.concat{ "Framerate:  ", tostring(__fps), " fps" },
        [2] = table.concat{ "Camera:     ", tostring(self.camera), " / ", tostring(#self.cameras) },
    }
end



--  Update a specific entity
local function updateEntity(self, dt, id)
    local entity = self.entities[id]
    if not entity then return end

    --  Update the entity's id
    entity.id = id

    --  Kill the entity if necessary
    if entity.kill then
        self:kill(id)

        return
    end

    --  Update matching systems
    for _, system in ipairs(self.systems) do

        if system:match(entity) then

            if not entity.loaded then
                system:load(entity)
            end

            system:update(dt, entity)
        end
    end

    entity.loaded = true
end



function M.update(self, dt)
    local currentCamera = self:getCamera()
    if not currentCamera then return end

    local camera = currentCamera:get("Camera")
    if not camera or not camera.isActive then return end

    --  Update camera zoom
    if kbd.isDown("lshift") then
        camera.fov = max(camera.fovMin, camera.fov - camera.zoomSpeed * dt)
    else
        camera.fov = min(camera.fovMax, camera.fov + camera.zoomSpeed * dt)
    end

    --  Update all entities
    for id = #self.entities, 1, -1 do
        updateEntity(self, dt, id)
    end

    --  Update map
    self.map:update(dt)
end



local function drawEntity(self, id)
    local entity = self.entities[id]
    if not entity then return end

    --  Update matching systems
    for _, system in ipairs(self.systems) do

        if system:match(entity) then
            system:draw(entity)
        end
    end
end



--  Draw the skybox with respect to the camera's rotation
--  NOTE This should be called by the camera system while rendering to its canvas
function M.drawSkybox(self)
    if not world.skybox then return end

    local camera = self:getCamera():get("Camera")
    local rotation = self:getCamera():get("Rotation")

    local isZoomed = camera.fov ~= camera.fovMax
    local fovPercent = camera.fov / camera.fovMax
    local scale = 1 / fovPercent

    world.skybox:draw(rotation.angle, scale)
end



--  Draw the floor
--  NOTE This should be called by the camera system while rendering to its canvas
function M.drawFloor(self)
    local camera = self:getCamera():get("Camera")
    local color = self.floorColor

    --  Stop here if no floor color is set
    if not color then return end

    Palette.set(color)

    local x,y = 0, 0
    local W,H = camera.canvas:getDimensions()
    local w,h = W, floor(H / 2)

    gfx.rectangle("fill", x, H - h, w, h)

    Palette.set("none")
end



--  Draws information to the screen
function M.drawInfo(self)
    local font = gfx.getFont()
    local info = self:getInfo()
    local margin = 8
    local x,y = margin, margin
    local w = font:getWidth(" ") * 24 + margin * 2
    local h = font:getHeight() * #info + margin * 2
    local alpha = 0.95
    
    --  Draw info box
    Palette.set("black", { a = alpha })
    gfx.rectangle("fill", x, y, w, h)

    --  Draw box outline
    Palette.set("white", { a = alpha })
    gfx.rectangle("line", x, y, w, h)

    --  Draw info text
    x = x + margin
    y = y + margin
    
    for i, line in ipairs(info) do
        local y = y + (i - 1) * font:getHeight()
        gfx.print(line, x, y)
    end

    Palette.set("none")
end



--  Draw everything
function M.draw(self)
    for id = #self.entities, 1, -1 do
        drawEntity(self, id)
    end

    local currentCamera = self:getCamera()
    if not currentCamera then return end

    local camera = currentCamera:get("Camera")
    if not camera or not camera.isActive then return end

    local W,H = gfx.getDimensions()
    local w,h = camera.canvas:getDimensions()
    local sx,sy = Vec2.new(W / w, H / h):normalize():unpack()
    local x,y = floor((W - w) / 2), floor((H - h) / 2)

    --  Draw the camera canvas to the screen
    gfx.draw(camera.canvas, x, y, 0, scale, scale)
    gfx.rectangle("line", x, y, w, h)

    --  Draw the map to the screen
    self.map:draw()

    --  Draw info to the screen
    self:drawInfo()
end



function M.new(data)
    local new = setmetatable({}, M)

    local data = data or {}
    new.grid = data.grid or {}
    new.entities = data.entities or {}
    new.textures = data.textures or {}

    --  Cameras
    new.cameraDimensions = data.cameraDimensions or Vec2.new(800, 600)
    new.cameras = data.cameras or {}
    new.camera = data.camera or 1

    --  Map
    local mapDimensions = data.mapDimensions or Vec2.new(max(new.cameraDimensions:unpack()) * pow(2, 0.5))
    new.map = Map.new({
        world = new,
        dimensions = mapDimensions,
        cameraDimensions = new.cameraDimensions,
        scale = 2,
        scaleZoomed = 1,
    })

    --  Floor
    new.floorColor = data.floorColor or "gray2"

    --  Skybox
    local skyboxDimensions = new.cameraDimensions * Vec2.new(1, 0.5)
    new.skybox = Skybox.new({ canvas = gfx.newCanvas(skyboxDimensions:unpack()) })

    --  Systems to register on load
    new._systems = data._systems or {
        [1] = CameraSystem.new(),
        [2] = MovementSystem.new(),
        [3] = RotationSystem.new(),
        [4] = PhysicsSystem.new{ meter = new.map.tileSize },
        [5] = IconSystem.new()
    }

    new:load()

    return new
end



return M
