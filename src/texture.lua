--[[

    Texture handling and caching

]]



local cache = {}



local M = {}
M.index = M
M.__name = "Texture"



--  Registers a texture to the cache.
function M.register(self)
    local dir = "res/texture/"
    local name = self.name
    local ext = ".png"
    local path = table.concat{ dir, name, ext }
    local image = gfx.newImage(path)
    cache[path] = image
end



--  Processes the texture image and break it up into 1px columns.
--
--  Textures are assumed to be made up of 64x64 pixel squares,
--  and depending on the proportions, the squares in in the
--  image will be used for each face as described below:
--
--     .------------------------------------------------.
--     | W:H | Square | Usage                           |
--     |------------------------------------------------|
--     | 1:1 |  1st   | All faces                       |
--     |-----|--------|---------------------------------|
--     | 1:2 |  1st   | All side faces                  |
--     |     |  2nd   | Bottom and top faces            |
--     |-----|--------|---------------------------------|
--     | 1:3 |  1st   | All side faces                  |
--     |     |  2nd   | Bottom face                     |
--     |     |  3rd   | Top face                        |
--     |-----|--------|---------------------------------|
--     | 1:4 |  1st   | Front and back faces            |
--     |     |  2nd   | Left and right faces            |
--     |     |  3rd   | Bottom face                     |
--     |     |  4th   | Top face                        |
--     |-----|--------|---------------------------------|
--     | 1:6 |  1st   | Front face                      |
--     |     |  2nd   | Left face                       |
--     |     |  3rd   | Back face                       |
--     |     |  4th   | Right face                      |
--     |     |  5th   | Bottom face                     |
--     |     |  6th   | Top face                        |
--     '------------------------------------------------'
--
--  NOTE At this time, top and bottom outside faces are invisible.
function M.process(self)
end



function M.load(self)
end



function M.update(self, dt)
end



--  Returns a quad representing a 1px wide column of a texture face.
--  NOTE Columns are zero-indexed.
function M.getColumn(self, col, face)
    local col = col or 0
    local face = face or 1
end



function M.new(data)
    local new = setmetatable({}, M)

    local data = data or {}
    new.name = data.name or "default"
    
    new:load()

    return new
end



return M
