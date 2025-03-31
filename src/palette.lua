--[[

    Color palette

]]



local gfx = love.graphics



local M = {}
M.__index = M
M.__name = "Palette"



M.colors = {
    none = {
        r = 1,
        g = 1,
        b = 1,
        a = 1,
    },

    transparent = {
        r = 0,
        g = 0,
        b = 0,
        a = 0,
    },

    black = {
        r = 0.035,
        g = 0.027,
        b = 0.074,
        a = 1,
    },

    gray6 = {
        r = 0.058,
        g = 0.047,
        b = 0.125,
        a = 1,
    },

    gray5 = {
        r = 0.137,
        g = 0.121,
        b = 0.325,
        a = 1,
    },

    gray4 = {
        r = 0.223,
        g = 0.219,
        b = 0.533,
        a = 1,
    },

    gray3 = {
        r = 0.411,
        g = 0.427,
        b = 0.741,
        a = 1,
    },

    gray2 = {
        r = 0.572,
        g = 0.584,
        b = 0.835,
        a = 1,
    },

    gray1 = {
        r = 0.682,
        g = 0.686,
        b = 0.894,
        a = 1,
    },

    white = {
        r = 0.835,
        g = 0.835,
        b = 0.929,
        a = 1,
    },

    red = {
        r = 0.894,
        g = 0.0,
        b = 0.117,
        a = 1,
    },

    orange = {
        r = 1.0,
        g = 0.172,
        b = 0.011,
        a = 1,
    },

    yellow = {
        r = 1.0,
        g = 0.564,
        b = 0.011,
        a = 1,
    },

    green = {
        r = 0.015,
        g = 0.819,
        b = 0.486,
        a = 1,
    },

    cyan = {
        r = 0.0,
        g = 0.615,
        b = 1.,
        a = 1,
    },

    blue = {
        r = 0.137,
        g = 0.113,
        b = 1.,
        a = 1,
    },

    indigo = {
        r = 0.192,
        g = 0.0,
        b = 0.694,
        a = 1,
    },

    pink = {
        r = 0.984,
        g = 0.160,
        b = 0.431,
        a = 1,
    },
}



local function get(name)
    local color = M.colors[name]

    return color
end



function M.get(name, rgba)
    local color = get(name)
    if not color then return end

    local rgba = rgba or {}

    return {
        rgba.r or color.r,
        rgba.g or color.g,
        rgba.b or color.b,
        rgba.a or color.a,
    }
end



function M.shade(color, shade, alpha)
    local color = get(color)
    local shade = get(shade)
    if not color or not shade then return end

    local function clamp(n, min, max)
        return n < min and min or (n > max and max or n)
    end

    return {
        clamp(color.r - (1 - shade.r), 0, 1),
        clamp(color.g - (1 - shade.g), 0, 1),
        clamp(color.b - (1 - shade.b), 0, 1),
        alpha or 1,
    }
end



function M.set(name, rgba)
    local color = get(name)
    if not color then return end

    local rgba = rgba or {}

    gfx.setColor {
        rgba.r or color.r,
        rgba.g or color.g,
        rgba.b or color.b,
        rgba.a or color.a,
    }
end



return M
