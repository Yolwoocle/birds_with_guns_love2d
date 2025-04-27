--[[
    [x] spr
    [ ] sspr
    [x] fget
    [x] fset
]]

local bit = require "bit"

function _load_sprite_flags()
    local data = love.filesystem.read("game/assets/sprite_flags.txt")
    assert(data ~= nil, "No sprite flag data found")
    
    local lines = split(data, "\n")
    assert(#lines == 2, "Invalid number of lines found in sprite_flags.txt (found "..tostring(#lines)..", expected 2)")
    
    data = lines[1]..lines[2]

    bytes_str = split(data, 2)
    __sprite_flags = {}
    for i=1, #bytes_str do
        __sprite_flags[i-1] = tonumber(bytes_str[i], 16)
    end
end

function spr(n, x, y, w, h, flip_x, flip_y)
    if not n then
        return
    end
    w = w or 1
    h = h or 1
    local sprite_w = 8
    local sprite_h = 8

    local sheet_w, sheet_h = __spritesheet:getDimensions()
    local sheet_tile_count_x = math.floor(sheet_w / sprite_w) 
    local sx = sprite_w * (n % sheet_tile_count_x)
    local sy = sprite_h * math.floor(n / sheet_tile_count_x) 
    if not __sprite_quad then
        __sprite_quad = love.graphics.newQuad(0, 0, sprite_w, sprite_h, sheet_w, sheet_h)
    end
    __sprite_quad:setViewport(sx, sy, sprite_w*w, sprite_h*h)

    local ox = sprite_w*w / 2
    local oy = sprite_h*h / 2

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(__spritesheet, __sprite_quad, x+ox, y+oy, 0, (flip_x and -1 or 1), (flip_y and -1 or 1), ox, oy)
    _set_love_color(__current_color)
end

function sspr(...)
    -- TODO
end

function fget(n, f)
    if not n then
        return
    end
    local flags = __sprite_flags[n] or 0
    if not f then
        return flags
    end
    return bit.band(bit.lshift(1, f), flags) > 0
end

function fset(n, f, v)
    if n < 0 or n > #__sprite_flags then
        return
    end

    if v == nil then
        __sprite_flags[n] = f
    else
        if v then
            __sprite_flags[n] = bit.bor(__transparency_mask, bit.lshift(1, f))
        else
            __sprite_flags[n] = bit.band(__transparency_mask, bit.bnot(bit.lshift(1, f)))
        end
    end
end