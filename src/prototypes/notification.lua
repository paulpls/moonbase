--[[

    Notification prototype

]]



local Palette = require "src.palette"
local Vec2 = require "src.prototypes.vec2"
local Timer = require "src.prototypes.timer"
local gfx = love.graphics
local kbd = love.keyboard
local max = math.max
local floor = math.floor



local M = {}
M.__index = M
M.__name = "Notification"



function M.update(self, dt)
    if self.kill then return end

    self.timer:update(dt)

    if not self.timer:isExpired() then
        return
    end

    if kbd.isDown("return") then
        self.kill = true
    end
end



function M.draw(self)
    if self.kill then return end

    local W,H = gfx.getDimensions()
    local font = gfx.getFont()
    local lines = 2

    local lineHeight = font:getHeight()
    local titleWidth = font:getWidth(self.title)
    local textWidth = font:getWidth(self.text)
    local w = max(titleWidth, textWidth) + self.padding.x * 2
    local h = lineHeight * (lines + 1) + self.padding.y * 3

    local x = floor((W - w) / 2)
    local y = floor((H - h) / 2)
    local _cursor = Vec2.new(x, y)

    --  Draw background
    Palette.set(self.colors.background)
    gfx.rectangle("fill", _cursor.x, _cursor.y, w, h)

    --  Draw border
    Palette.set(self.colors.foreground)
    gfx.rectangle("line", _cursor.x, _cursor.y, w, h)

    _cursor = _cursor + self.padding

    --  Title (in bold)
    gfx.print(self.title, _cursor.x, _cursor.y)
    gfx.print(self.title, _cursor.x + 1, _cursor.y)

    _cursor.y = _cursor.y + lineHeight + self.padding.y

    --  Text
    gfx.print(self.text, _cursor.x, _cursor.y)

    Palette.set("none")
end



function M.new(data)
    local new = setmetatable({}, M)

    local data = data or {}
    new.title = data.title or new.__name
    new.text = data.text or ""
    new.padding = data.padding or Vec2.new(48, 24)
    new.kill = false
    --  Timer
    new.timer = data.timer or Timer.new{ duration = 0.25 }
    --  Colors
    data.colors = data.colors or {}
    new.colors = {
        background = data.colors.background or "black",
        foreground = data.colors.foreground or "white",
    }

    return new
end



return M
