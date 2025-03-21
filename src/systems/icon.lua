--[[

    Icon system

]]



local System = require "src.prototypes.system"
local gfx = love.graphics



local M = {}
M.__index = M
M.__name = "Icon"



local cache = {}



M.components = {
    "Icon",
}



function M.load(self, entity)
    local icon = entity:get("Icon")
    local separator = package.config:sub(1, 1)
    local filename = table.concat{ icon.name, ".png" }
    local path = table.concat({ icon.path, filename }, separator)

    --  Fetch image from cache if available, or add to the cache
    local image = cache[path]
    
    if not image then
        image = gfx.newImage(path)
        cache[path] = image
    end

    icon.image = image
end




function M.new(data)
    local data = data or {}

    data.load = data.load or M.load

    return System.new(M.__name, M.components, data)
end



return M
