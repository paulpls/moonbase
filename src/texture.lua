--[[

    Texture handling and caching

]]



local floor = math.floor
local gfx = love.graphics



local textures = {}



local M = {}
M.index = M
M.__name = "Texture"



--  Registers a texture to the textures cache.
function M.register(self, override)
    local dir = "res/texture/"
    local name = self.name
    local ext = ".png"
    local path = table.concat{ dir, name, ext }

    local override = override and true or false
    if textures[path] and not override then return end

    local image = gfx.newImage(path)
    textures[path] = image
end



--  Ascertains the layout of the texture image as described below in `process()`
local function getLayout(numFaces)
    local faces = {
        [1] = { front = 1, left = 1, back = 1, right = 1, bottom = 1, top = 1, },
        [2] = { front = 1, left = 1, back = 1, right = 1, bottom = 2, top = 2, },
        [3] = { front = 1, left = 1, back = 1, right = 1, bottom = 2, top = 3, },
        [4] = { front = 1, left = 2, back = 1, right = 2, bottom = 3, top = 4, },
        [6] = { front = 1, left = 2, back = 3, right = 4, bottom = 5, top = 6, },
    }

    return faces[numFaces] or faces[1]
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
--     | 1:1 |  1st   | All faces (used as fallback)    |
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
    local image = self.image
    local w = image:getWidth()
    local size = 64
    local numFaces = floor(w / size)
    self.layout = getLayout(numFaces)
    self.faces = {}

    --  Create a list of quads (columns) for each face
    for face = 1, numFaces do
        local newFace = {}

        --  Columns are zero-indexed because they correspond to pixel coordinates
        for col = 0, size - 1 do
            local x = (face - 1) * size + col
            local y = 0
            local quad = gfx.newQuad(x, y, size, sizw)
            newFace[col] = quad
        end

        self.faces]face] = newFace
    end
end



function M.load(self)
    self:register()
    self:process()
end



function M.update(self, dt)
end



--  Given the name of a face, returns a quad representing a 1px-wide
--  column of the texture. Defaults to the `front` face, column zero.
--  NOTE Columns are zero-indexed.
function M.getColumn(self, face, col)
    local face = self.layout[face or "front"]
    local col = col or 0

    return self.faces[face][col]
end



function M.new(data)
    local new = setmetatable({}, M)

    local data = data or {}
    new.name = data.name or "default"

    new:load()

    return new
end



return M
