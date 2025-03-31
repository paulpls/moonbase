--[[

    Physics system

]]



local System = require "src.prototypes.system"
local Vec2 = require "src.prototypes.vec2"
local floor = math.floor
local phys = love.physics



local M = {}
M.__index = M
M.__name = "Physics"




M.components = {
    "Body",
    "Physics",
}



--  Tie the entity body's position to that of the physics collider
local function resetBodyPosition(body, physics)
    local x,y = physics.body:getPosition()
    local w,h = physics.dimensions.x, physics.dimensions.y
    x = x - floor(w / 2)
    y = y - floor(h / 2)

    body.position = Vec2.new(x, y)
end



function M.addCollisionClasses(self, fixture, collision)
    local _classes = {}

    for _, name in ipairs(collision.classList) do
        local id = self:getClass(name)

        if not id then
            id = self:addClass(name)
        end

        if #_classes <= 16 then
            table.insert(_classes, id)

            id = self:getClass(name)
            collision.classes[id] = name
        end
    end

    if #_classes > 0 then
        fixture:setCategory(unpack(_classes))
    end
end



function M.addCollisionMask(self, fixture, collision)
    local _classes = {}

    local ignoreList = collision.ignoreList or {}

    for _, name in ipairs(ignoreList) do
        local id = self:getClass(name)

        if not id then
            id = self:addClass(name)
        end

        --  Physics engine enforces a maximum number of 16 classes in total
        if #_classes <= 16 then
            table.insert(_classes, id)

            id = self:getClass(name)
            collision.ignores[id] = name
        end
    end

    if #_classes > 0 then
        fixture:setMask(unpack(_classes))
    end
end



local function handleCollisions(name, a, b, contact, normal, tangent)
    local a = a:getUserData()
    local b = b:getUserData()
    local aCol,bCol = a:get("Collision"), b:get("Collision")
    if not aCol or not bCol then return end

    local callbacks = {}

    for id, handler in pairs(aCol.handlers) do
        for _id, class in ipairs(bCol.classList) do
            if id == class then
                local callback = handler[name]
                if callback then table.insert(callbacks, callback) end
            end
        end
    end

    for _, action in ipairs(callbacks) do
        action(a, b, contact, normal, tangent)
    end
end



local function beginContact(a, b, contact, normal, tangent)
    handleCollisions("beginContact", a, b, contact, normal, tangent)
end



local function endContact(a, b, contact, normal, tangent)
    handleCollisions("endContact", a, b, contact, normal, tangent)
end



local function preSolve(a, b, contact, normal, tangent)
    handleCollisions("preSolve", a, b, contact, normal, tangent)
end



local function postSolve(a, b, contact, normal, tangent)
    handleCollisions("postSolve", a, b, contact, normal, tangent)
end



function M.getClass(self, name)
    for id, class in ipairs(self.classes) do
        if name == class then return id end
    end
end



function M.addClass(self, name)
    if #self.classes >= 16 then return end
    table.insert(self.classes, name)

    return #self.classes
end



function M.delClass(self, id)
    if not self:getClassId(id) then return end
    table.remove(self.classes, id)
end



function M.kill(self, entity)
    local physics = entity:get("Physics")

    physics.body:destroy()
end



function M.load(self, entity)
    phys.setMeter(self.meter)

    local body = entity:get("Body")
    local physics = entity:get("Physics")
    local collision = entity:get("Collision")
    
    local position = body.position
    physics.dimensions = physics.dimensions or body.dimensions

    if not physics.body then
        local x = position.x + physics.dimensions.x / 2
        local y = position.y + physics.dimensions.y / 2
        physics.body = phys.newBody(self.world, x, y, physics.state)
        physics.body:setMass(physics.mass)
        physics.body:setLinearDamping(physics.linearDamping)
        physics.body:setBullet(physics.isBullet or false)

        if not physics.canRotate then
            physics.body:setFixedRotation(true)
        end
    end

    resetBodyPosition(body, physics)

    local rotation = entity:get("Rotation")

    if rotation then
        physics.body:setAngle(rotation.angle)
    end

    if not physics.shape then
        local w = physics.dimensions.x
        local h = physics.dimensions.y
        physics.shape = phys.newRectangleShape(w, h)
    end

    --  Set circle radius to the average of the collider dimensions, if applicable
    if physics.shape:getType() == "circle" then
        local avg = physics.dimensions:unpack() / 2
        physics.shape:setRadius(avg)
    end

    if not physics.fixture then
        physics.fixture = phys.newFixture(physics.body, physics.shape)
        physics.fixture:setUserData(entity)
        physics.fixture:setSensor(physics.isSensor or false)

        if collision then
            self:addCollisionClasses(physics.fixture, collision)
            self:addCollisionMask(physics.fixture, collision)
        end

        if physics.restitution then
            physics.fixture:setRestitution(physics.restitution)
        end
    end
end



function M.update(self, dt, entity)
    local body = entity:get("Body")
    local physics = entity:get("Physics")
    local rotation = entity:get("Rotation")

    if rotation then
        physics.body:setAngle(rotation.angle)
    end

    self.world:update(dt)

    resetBodyPosition(body, physics)
end



function M.new(data)
    local data = data or {}

    data.meter = data.meter or 1
    data.gravity = data.gravity or 0
    data.world = data.world

    if not data.world then
        data.world = phys.newWorld(0, data.meter * data.gravity, true)
        data.world:setCallbacks(beginContact, endContact, preSolve, postSolve)
    end

    data.classes = data.classes or { [1] = "Default" }

    data.kill = data.kill or M.kill
    data.load = data.load or M.load
    data.update = data.update or M.update

    data.getClass = M.getClass
    data.addClass = M.addClass
    data.delClass = M.delClass
    data.addCollisionClasses = M.addCollisionClasses
    data.addCollisionMask = M.addCollisionMask

    return System.new(M.__name, M.components, data)
end



return M
