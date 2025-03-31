--[[

    Notification prototype

]]



local Palette = require "src.palette"
local gfx = love.graphics
local kbd = love.keyboard
local max = math.max
local floor = math.floor



local M = {}
M.__index = M
M.__name = "Notification"



function M.update(self, dt)
    if self.kill then return end

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
    local w = max(titleWidth, textWidth) + self.padding * 2
    local h = lineHeight * (lines + 1) + self.padding * 4

    local x = floor((W - w) / 2)
    local y = floor((H - h) / 2)

    --  Draw background
    Palette.set(self.colors.background)
    gfx.rectangle("fill", x, y, w, h)

    --  Draw border
    Palette.set(self.colors.foreground)
    gfx.rectangle("line", x, y, w, h)

    --  Title (in bold)
    gfx.print(self.title, x + self.padding, y + self.padding)
    gfx.print(self.title, x + self.padding + 1, y + self.padding)

    --  Text
    y = y + lineHeight
    gfx.print(self.text, x + self.padding, y + self.padding)

    Palette.set("none")
end



function M.new(data)
    local new = setmetatable({}, M)

    local data = data or {}
    new.title = data.title or new.__name
    new.text = data.text or ""
    new.padding = data.padding or 8
    new.kill = false
    --  Colors
    data.colors = data.colors or {}
    new.colors = {
        background = data.colors.background or "black",
        foreground = data.colors.foreground or "white",
    }

    return new
end



return M
