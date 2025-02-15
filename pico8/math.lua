--[[
    # Math
    min
    max
    mid
    rnd
    rrnd
    flr
    ceil
    sqrt
    abs
    atan2
    cos
    sin
]]

--- min( first, [second] )
-- Returns the minimum of two numbers.  
-- first  
--     The first number.  
-- second  
--     The second number. (default 0)  
function min(x, y)
    y = y or 0
    return math.min(x, y)
end

--- max( first, [second] )
-- Returns the maximum of two numbers.  
-- first  
--     The first number.  
-- second  
--     The second number. (default 0)  
function max(x, y)
    y = y or 0
    return math.max(x, y)
end

--- mid( first, second, third )
--     Returns the middle of three numbers. Also useful for clamping.
--     first
--         The first number.
--     second
--         The second number.
--     third
--         The third number.
function mid(a, b, c)
    if (a > b) then
        b, a = a, b
    end
    if (a > c) then
        c, a = a, c
    end
    if (b > c) then
        c, b = b, c
    end
    return b
end

function rnd(val)
    val = val or 1.0
    if type(val) == "number" then
        return love.math.random() * val
    elseif type(val) == "table" then
        return val[love.math.random(1, #val)]
    else
        return 0
    end
end

flr = math.flr
ceil = math.ceil
abs = math.abs

function sqrt(val)
    return math.sqrt(math.max(0.0, val))
end

function atan2(dx, dy)
    if dx == 0 and dy == 0 then
        return 0.25
    end
    return (math.atan2(-dy, dx) % (math.pi * 2)) / (math.pi * 2)
end

function cos(x)
    return math.cos((x % 1.0) * (math.pi * 2))
end

function sin(x)
    return -math.sin((x % 1.0) * (math.pi * 2))
end


