--[[

    Entity prototype

]]



local Component = require "src.prototypes.component"
local FileIO = require "src.fileIO"



local M = {}
M.__index = M
M.__name = "Entity"



--  Add a new component to the entity
function M.add(self, component)
    local id = component.id
    self.components[id] = component
end



--  Delete a component from the entity
--  Returns deleted component
function M.del(self, id)
    local component = self.components[id]
    self.components[id] = nil

    return component
end



--  Returns true if entity has the specified component
function M.has(self, id)
    return self.components[id] ~= nil
end



--  Returns the specified component if entity has it
function M.get(self, id)
    return self.components[id]
end



--  Build component data
local function loadComponent(name, data)
    local data = data

    --  Filenames are converted to lowerCamelCase, then the full path is built
    local name = name:gsub("^%u", string.lower)
    local file = table.concat{ name, ".lua" }
    local path = { "src", "components", file }

    --  NOTE Files are loaded using `FileIO.load(path)` instead of `require`
    --  to enforce uncached loading of data, yielding unique components.
    --  If `require` were used here instead, all like components' data would
    --  share the same memory addresses, leading to singleton-like behavior.
    local Prefab, err = FileIO.load(path)

    --  Find existing prefab components, or make a new one using the prototype
    if Prefab then
        return Prefab.new(data)
    else
        return Component.new(name, data)
    end
end



--  Load prefabricated components from files, or create new base components
local function getComponents(data, overrides)
    local components = {}

    for name, componentData in pairs(overrides) do

        if not data[name] then
            data[name] = {}
        end

        for k,v in pairs(componentData) do
            data[name][k] = v
        end
    end

    for name, componentData in pairs(data) do
        components[name] = loadComponent(name, componentData)
    end

    return components
end



local function loadData(entityType, entityName)
    if not entityType then return end
    
    local entityType = entityType:gsub("^%u", string.lower)
    local entityName = entityName and entityName:gsub("^%u", string.lower) or "default"
    local file = table.concat{ entityName, ".lua" }
    local path = { "data", "entity", entityType, file }
    local defaultPath = { "data", "entity", entityType, "default.lua" }
    local data = FileIO.exists(path) and FileIO.load(path) or FileIO.load(defaultPath)

    if not data then
        local separator = package.config:sub(1, 1)
        print("Missing data:", table.concat(defaultPath, separator))
        
        return {}
    end

    data.components = data.components or {}

    return data
end



function M.new(entityType, entityName, components)
    local entityType = entityType and entityType:gsub("^%l", string.upper) or "Default"
    local entityName = entityName and entityName:gsub("^%l", string.upper) or "Default"
    local components = components or {}

    local new = setmetatable({}, M)
    new.__type = entityType
    new.__name = entityName
    new.id = 0

    new.kill = false

    local data = loadData(entityType, entityName) or {}
    new.components = getComponents(data.components, components)

    return new
end



return M
