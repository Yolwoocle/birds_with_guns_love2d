require "pico8.math"

--[[
    [x] cls
    [ ] camera
    [ ] map
    [x] spr
    [ ] sspr
    [x] print
    [x] line
    [x] rectfill
    [x] rect
    [x] circ
    [x] circfill
]]

function cls(color)
    love.graphics.clear(__colors[__palette[color]])
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
    love.graphics.setColor(__colors[__palette[__current_color]])
end

function sspr(...)
    -- TODO
end

function map(...)
    -- TODO
end

function camera(cx, cy)
    cx = cx or 0
    cy = cy or 0
    __camera_x = cx
    __camera_y = cy
end

function pset(_px, _py, _c)
    if _c then
        __current_color = _c
    else
        _c = __current_color
    end

    love.graphics.setColor(__colors[__palette[_c]])
    love.graphics.points(flr(_px) + 0.5,
                         flr(_py) + 0.5)
end


function rect(_px1, _py1, _px2, _py2, _c)
    if _c then
        __current_color = _c
    else
        _c = __current_color
    end

    local x = flr(min(_px1, _px2)) + 0.5
    local y = flr(min(_py1, _py2)) + 0.5
    local w = abs(_px1 - _px2) 
    local h = abs(_py1 - _py2)

    love.graphics.setColor(__colors[__palette[_c]])
    love.graphics.rectangle("line", x, y, w, h)
end

function rectfill(_px1, _py1, _px2, _py2, _c)
    if _c then
        __current_color = _c
    else
        _c = __current_color
    end

    local x = flr(min(_px1, _px2))
    local y = flr(min(_py1, _py2))
    local w = abs(_px1 - _px2) +1
    local h = abs(_py1 - _py2) +1

    love.graphics.setColor(__colors[__palette[_c]])
    love.graphics.rectangle("fill", x, y, w, h)
end


function circ(x, y, r, col)
    r = r or 4
    if col then
        __current_color = col
    else
        col = __current_color
    end

    love.graphics.setColor(__colors[__palette[col]])
    love.graphics.circle("line", x, y, r)
end

function circfill(x, y, r, col)
    -- Due to how LÖVE interpolates and draws circles, this is not accurate to PICO-8
    r = r or 4 
    if col then
        __current_color = col
    else
        col = __current_color
    end

    love.graphics.setColor(__colors[__palette[col]])
    love.graphics.circle("fill", x, y, r)
end


function line(px1, py1, px2, py2, col)
    if col then
        __current_color = col
    else
        col = __current_color
    end

    love.graphics.setColor(__colors[__palette[col]])
    love.graphics.line(flr(px1) +0.5, flr(py1) +0.5, flr(px2) +0.5, flr(py2) +0.5)
end

console_print = print
function print(_str, _x, _y, col)
    _str = tostring(_str)
    local px = flr(_x)
    local x0 = px
    local y0 = flr(_y)

    if col then
        __current_color = col
    else
        col = __current_color
    end

    love.graphics.setColor(__colors[__palette[col]])

    love.graphics.setFont(__font)
    love.graphics.print(_str, flr(x0), flr(y0))
end