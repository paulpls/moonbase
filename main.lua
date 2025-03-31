--[[

    Moonbase - Extensible raycasting engine for LÖVE

]]



local Palette = require "src.palette"
local World = require "src.world"
local Vec2 = require "src.prototypes.vec2"
local Entity = require "src.prototypes.entity"
local floor = math.floor
local gfx = love.graphics
local win = love.window
local kbd = love.keyboard



local TAU = math.pi * 2



function love.load()
    win.setFullscreen(true)
    gfx.setBackgroundColor(Palette.get("black"))
    gfx.setDefaultFilter("nearest", "nearest")

    --  Use a fixed-width font please and thank you
    local fontImage = "res/font/mono.png"
    local fontGlyphs = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789.,?!:;'\"-+*/()[]{} "
    gfx.setFont(gfx.newImageFont(fontImage, fontGlyphs))

    --  Initialize the world
    world = World.new()

    world:add(Entity.new("block", "default", {
        Body = {
            position = Vec2.new(0, 0),
        },
    }))

    world:add(Entity.new("block", "default",{
        Body = {
            position = Vec2.new(1, 0),
        },
    }))

    world:add(Entity.new("block", "default", {
        Body = {
            position = Vec2.new(2, 0),
        },
    }))

    world:add(Entity.new("block", "default", {
        Body = {
            position = Vec2.new(4, 0),
        },
    }))

    world:add(Entity.new("block", "default", {
        Body = {
            position = Vec2.new(5, 0),
        },
    }))

    world:add(Entity.new("block", "default", {
        Body = {
            position = Vec2.new(6, 0),
        },
    }))

    world:add(Entity.new("block", "default", {
        Body = {
            position = Vec2.new(6, 1),
        },
    }))

    world:add(Entity.new("block", "default", {
        Body = {
            position = Vec2.new(6, 2),
        },
    }))

    world:add(Entity.new("block", "default", {
        Body = {
            position = Vec2.new(6, 4),
        },
    }))

    world:add(Entity.new("block", "default", {
        Body = {
            position = Vec2.new(6, 5),
        },
    }))

    world:add(Entity.new("block", "default", {
        Body = {
            position = Vec2.new(6, 6),
        },
    }))

    world:add(Entity.new("block", "default", {
        Body = {
            position = Vec2.new(0, 1),
        },
    }))

    world:add(Entity.new("block", "default", {
        Body = {
            position = Vec2.new(0, 2),
        },
    }))

    world:add(Entity.new("block", "default", {
        Body = {
            position = Vec2.new(0, 4),
        },
    }))

    world:add(Entity.new("block", "default", {
        Body = {
            position = Vec2.new(0, 5),
        },
    }))

    world:add(Entity.new("block", "default", {
        Body = {
            position = Vec2.new(0, 6),
        },
    }))

    world:add(Entity.new("block", "default", {
        Body = {
            position = Vec2.new(1, 6),
        },
    }))

    world:add(Entity.new("block", "default", {
        Body = {
            position = Vec2.new(2, 6),
        },
    }))

    world:add(Entity.new("block", "default", {
        Body = {
            position = Vec2.new(4, 6),
        },
    }))

    world:add(Entity.new("block", "default", {
        Body = {
            position = Vec2.new(5, 6),
        },
    }))

    world:add(Entity.new("block", "window", {
        Body = {
            position = Vec2.new(3, 3),
        },
    }))

    world:add(Entity.new("block", "hazard", {
        Body = {
            position = Vec2.new(8, 5),
        },
    }))

    world:add(Entity.new("block", "custom", {
        Body = {
            position = Vec2.new(7, 5),
        },
        Collision = {
            handlers = {
                Camera = {
                    beginContact = require("src.behaviors.notifyCollision"),
                },
            },
        },
    }))
end



--  Calculate the average framerate
local function updateFramerateInfo(dt)
    if not __framerates then __framerates = {} end

    local n = 60

    if #__framerates > n then
        table.remove(__framerates, 1)
    end

    table.insert(__framerates, floor(1 / dt))

    local total, count = 0, #__framerates

    for _, rate in pairs(__framerates) do
        total = total + rate
    end

    __fps = #__framerates >= n and floor(total / count) or "--"
end



function love.update(dt)
    updateFramerateInfo(dt)

    --  Update world, halt further updates if notifications are present
    --  TODO Move keyboard controls to separate module
    if world then world:update(dt) end
    if world and world.notifications:peek() then return end

    --  Update the camera
    local camera = world:getCamera()
    local movement = camera:get("Movement")
    local rotation = camera:get("Rotation")

    --  Move camera forward or backward
    if kbd.isDown("w") then
        movement.direction = 0
    elseif kbd.isDown("s") then
        movement.direction = TAU / 2
    end

    --  Pan camera left or right
    if kbd.isDown("a") then
        movement.direction = 3 * TAU / 4
    elseif kbd.isDown("d") then
        movement.direction = TAU / 4
    end

    --  Rotate camera
    if kbd.isDown("left") then
        rotation.delta = -1
    elseif kbd.isDown("right") then
        rotation.delta = 1
    end
end



function love.draw()
    if world then world:draw() end
end



function love.keypressed(key)
    --  Quit
    if key == "escape" then love.event.quit() end

    --  Toggle texture rendering
    if key == "tab" then
        local camera = world:getCamera():get("Camera")

        camera.renderTextures = not camera.renderTextures
    end

    --  Zoom the map
    if key == "z" then
        world.map.isZoomed = not world.map.isZoomed
    end

    --  Toggle map style
    if key == "m" then
        world.map.isRelative = not world.map.isRelative
    end

    --  Toggle physics colliders in map
    if key == "c" then
        world.map.renderPhysics = not world.map.renderPhysics
    end

    --  Create a new camera
    if key == "n" then
        world:addCamera()
    end

    --  Set active camera to the first camera
    if key == "h" then
        world:selectFirstCamera()
    end

    --  Set active camera to the next camera
    if key == "j" then
        world:selectNextCamera()
    end

    --  Set active camera to the previous camera
    if key == "k" then
        world:selectPreviousCamera()
    end

    --  Set active camera to the last camera
    if key == "l" then
        world:selectLastCamera()
    end
end



function love.quit()
    --  Bye, Felicia
end
