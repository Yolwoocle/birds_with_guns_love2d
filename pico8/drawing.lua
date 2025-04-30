require "pico8.math"

--[[
    [x] cls
    [x] camera
    [x] map
    [x] spr
    [ ] sspr
    [x] print (renamed to print_)
    [x] line
    [x] rectfill
    [x] rect
    [x] circ
    [x] circfill
]]

function _set_love_color(col)
    love.graphics.setColor(col/255, 0, 0, 1)
end

function _set_layer(id)
    __canvas = __layers[id]
    love.graphics.setCanvas(__canvas)
end

function cls(color)
    color = color or 0
    love.graphics.clear(color/255, 0, 0, 1)
end

function camera(cx, cy)
    cx = cx or 0
    cy = cy or 0
    __camera_x = math.floor(cx)
    __camera_y = math.floor(cy)
end

function pset(px, py, col)
    rectfill(px, py, px, py, col)
end


function rect(px1, py1, px2, py2, col)
    if col then
        __current_color = col
    else
        col = __current_color
    end

    local x = flr(min(px1, px2)) + 0.5
    local y = flr(min(py1, py2)) + 0.5
    local w = abs(px1 - px2) 
    local h = abs(py1 - py2)

    _set_love_color(col)
    __shader_pico8_draw:send("transparencyEnabled", false)
    love.graphics.rectangle("line", x, y, w, h)
    __shader_pico8_draw:send("transparencyEnabled", true)
end

function rectfill(px1, py1, px2, py2, col)
    if col then
        __current_color = col
    else
        col = __current_color
    end

    local x = flr(min(px1, px2))
    local y = flr(min(py1, py2))
    local w = abs(px1 - px2) +1
    local h = abs(py1 - py2) +1

    _set_love_color(col)
    __shader_pico8_draw:send("transparencyEnabled", false)
    love.graphics.rectangle("fill", x, y, w, h)
    __shader_pico8_draw:send("transparencyEnabled", true)
end

function circ(x, y, r, col)
    r = r or 4
    if col then
        __current_color = col
    else
        col = __current_color
    end

    _set_love_color(col)
    __shader_pico8_draw:send("transparencyEnabled", false)
    love.graphics.circle("line", x, y, r)
    __shader_pico8_draw:send("transparencyEnabled", true)
end

function circfill(x, y, r, col)
    -- Due to how LÖVE interpolates and draws circles, this is not accurate to PICO-8
    r = r or 4 
    if col then
        __current_color = col
    else
        col = __current_color
    end

    _set_love_color(col)
    __shader_pico8_draw:send("transparencyEnabled", false)
    love.graphics.circle("fill", x, y, r)
    __shader_pico8_draw:send("transparencyEnabled", true)
end


function line(px1, py1, px2, py2, col)
    if col then
        __current_color = col
    else
        col = __current_color
    end

    _set_love_color(col)
    __shader_pico8_draw:send("transparencyEnabled", false)
    love.graphics.line(flr(px1) +0.5, flr(py1) +0.5, flr(px2) +0.5, flr(py2) +0.5)
    __shader_pico8_draw:send("transparencyEnabled", true)
end

function print_(_str, _x, _y, col)
    _str = tostring(_str)
    local px = flr(_x)
    local x0 = px
    local y0 = flr(_y)

    if col then
        __current_color = col
    else
        col = __current_color
    end

    _set_love_color(col+1)
    love.graphics.setFont(__font)
    __shader_pico8_draw:send("transparencyEnabled", false)
    love.graphics.print(_str, flr(x0), flr(y0))
    __shader_pico8_draw:send("transparencyEnabled", true)
end

function print_pinball(_str, _x, _y, col)
    local old_font = __font
    __font = __font_pinball

    print_(_str, _x, _y, col)

    __font = old_font
end