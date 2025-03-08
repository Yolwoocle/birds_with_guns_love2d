--[[
    poke
    peek
    stat
    mset
    mget
    fget
    fset
]]

local bit = require "bit"

function poke(...)
    -- TODO
end

function peek(...)
    -- TODO
    return 0
end

local function _get_mouse_pos()
    if not (__canvas_ox and __canvas_oy and __canvas_scale) then
        return 0, 0
    end
    local mx, my = love.mouse.getPosition()
    mx = (mx - __canvas_ox) / __canvas_scale
    my = (my - __canvas_oy) / __canvas_scale
    return math.floor(mx), math.floor(my)
end

function stat(n)
    -- TODO
    if n == 6 then
        --[[ TODO
            {6} Parameter string from a third-party load
            When a cart calls load() to load another cart, it can provide an arbitrary 
            string as the third argument. This string is accessible to the loaded cart 
            by calling stat(6). If PICO-8 is run from the command line, the -p flag can 
            be used to provide this argument instead.

            If the load() call also included a breadcrumb string, the loaded cart can 
            access this with stat(100). 
        ]]
        return __breadcrumb

    elseif n == 32 then
        local mx, my = _get_mouse_pos()
        return mx
    elseif n == 33 then
        local mx, my = _get_mouse_pos()
        return my
    elseif n == 34 then
        return tonum(love.mouse.isDown(3)) * 4 + tonum(love.mouse.isDown(2)) * 2 + tonum(love.mouse.isDown(1))
    elseif n == 36 then
        return (__mouse_wheel_state or 0)
    end
    -- 32 33 34 36 6
    return nil
end
