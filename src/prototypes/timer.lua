--[[

    Timer prototype

]]



local max = math.max



local M = {}
M.__index = M
M.__name = "Timer"



function M.start(self)
    self._active = true
end



function M.stop(self)
    self._active = false
end



function M.reset(self, duration)
    self.duration = duration or self.duration
    self._time = self.duration
end



function M.isExpired(self)
    return self._time <= 0
end



function M.isActive(self)
    return self._active ~= nil and self._active or false
end



function M.update(self, dt)
    --  Stop if expired or not active
    if self:isExpired() or not self:isActive() then return end

    --  Subtract from remaining time and activate payload if finished
    self._time = max(0, self._time - dt)
    
    if self._time == 0 then
        self.payload()
    end
end



function M.new(data)
    local new = setmetatable({}, M)

    local data = data or {}
    new.duration = data.duration or 0
    new._time = new.duration
    new.payload = data.payload or function() return end

    if not data.paused then
        new:start()
    end

    return new
end



return M
