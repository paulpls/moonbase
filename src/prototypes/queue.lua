--[[

    Queue prototype

    TODO [Performant double queue](https://www.lua.org/pil/11.4)
         For now, this implementation is just fine for the project's needs.

]]



local M = {}
M.__index =  M
M.__name = "Queue"



--  Pushes a new element to the back of the queue.
function M.add(self, data)
    if not data then return end

    table.insert(self.queue, 1, data)
end



--  Returnss the first element in the queue.
function M.peek(self)
    if self:isEmpty() then return end

    return self.queue[#self.queue]
end



--  Returns the first element in the queue and removes it.
function M.remove(self)
    local element = self:peek()
    if not element then return end

    self.queue[#self.queue] = nil

    return element
end



--  Returns true if the queue is empty.
function M.isEmpty(self)
    return #self.queue == 0
end



function M.new(data)
    local new = setmetatable({}, M)

    local data = data or {}
    new.queue = data.queue or {}

    return new
end



return M
