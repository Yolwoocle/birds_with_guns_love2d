--[[
    poke
    peek
    stat
    mset
    mget
    fget
    fset
]]

function poke(...)
    -- TODO
end

function peek(...)
    -- TODO
    return 0
end

function get_mouse_pos()
    local mx, my = love.mouse.getPosition()
    mx = (mx - __canvas_ox) / __canvas_scale
    my = (my - __canvas_oy) / __canvas_scale
    return mx, my
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
        return 0

    elseif n == 32 then
        local mx, my = get_mouse_pos()
        return mx
    elseif n == 33 then
        local mx, my = get_mouse_pos()
        return my
    elseif n == 34 then
        return tonum(love.mouse.isDown(3)) * 4 + tonum(love.mouse.isDown(2)) * 2 + tonum(love.mouse.isDown(1))
    elseif n == 36 then
        return (__mouse_wheel_state or 0)
    end
    -- 32 33 34 36 6
    return nil
end

function mset(...)
    -- TODO
end

function mget(...)
    -- TODO
    return 0
end

function fget(...)
    -- TODO
end

function fset(...)
    -- TODO
    return 0
end
