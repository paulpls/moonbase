--[[

    File operations

]]



local M = {}
M.__index = M
M.__name = "FileIO"



local function sanitize(path)
    local path = path

    if type(path) == "table" then
        local separator = package.config:sub(1, 1)
        path = table.concat(path, separator)
    end

    return path
end



function M.exists(path)
    local path = sanitize(path)
    local file = io.open(path, "rb")
    if file then file:close() end

    return file ~= nil
end



function M.read(path)
    local _lines = {}
    if not M.exists(path) then return _lines end

    for line in io.lines(path) do
        table.insert(_lines, line)
    end

    return _lines
end



--  NOTE When using `require` for shared data files, all instances that load the
--  same file will have shared pointers in memory because the cached version is
--  used. Using `load(path)` will ensure that the file is loaded fresh every time,
--  without manipulating the cache, as well as returning any errors thrown.
function M.load(path)
    local path = sanitize(path)
    local file, err = loadfile(path)

    if M.exists(path) and err then
        print(table.concat{ "Error: ", err })
    end

    if file then
        return file()
    else
        local msg = table.concat{ "FileIO: Unable to load file: `", path, "`" }

        return nil, msg
    end
end



--  Write contents to file
function M.write(path, contents)
    local file = io.open(path, "w")
    file:write(contents)
    file:close()
end



return M
