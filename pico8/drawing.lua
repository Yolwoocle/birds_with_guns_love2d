require "pico8.math"

--[[
    cls
    camera
    map
    spr
    print
    line
    rectfill
    rect
    circ
    circfill
]]

function cls(color)
    love.graphics.clear(__colors[__palette[color]])
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
    love.graphics.line( flr(px1) +0.5, flr(py1) +0.5, flr(px2) +0.5, flr(py2) +0.5)
end


function pprint(_str, _x, _y, col)
    _str = tostring(_str)
    local px = flr(_x)
    local x0 = px
    local y0 = flr(_y)

    if col then
        __current_color = col
    else
        col = __current_color
    end

    -- todo mangage characters like ⬅️ (=2 characters)
    love.graphics.setColor(__colors[__palette[col]])

    love.graphics.setFont(__font)
    love.graphics.print(_str, flr(x0), flr(y0))
end