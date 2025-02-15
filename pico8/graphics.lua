--[[
    # Graphics
    cls
    pal
    palt
    camera
    map
    spr
    sspr
    print
    line
    rectfill
    rect
    circ
    circfill
    color
]]

function _init_graphics()
    -- Big thanks to Johan Peitz 
    __colors = {
        [0] = { 0, 0, 0, 255 },
        [1] = { 29, 43, 83, 255 },
        [2] = { 126, 37, 83, 255 },
        [3] = { 0, 135, 81, 255 },

        [4] = { 171, 82, 54, 255 },
        [5] = { 95, 87, 79, 255 },
        [6] = { 194, 195, 199, 255 },
        [7] = { 255, 241, 232, 255 },

        [8] = { 255, 0, 77, 255 },
        [9] = { 255, 163, 0, 255 },
        [10] = { 255, 236, 39, 255 },
        [11] = { 0, 228, 54, 255 },

        [12] = { 41, 173, 255, 255 },
        [13] = { 131, 118, 156, 255 },
        [14] = { 255, 119, 168, 255 },
        [15] = { 255, 204, 170, 255 },
    }

    for i = 0, #__colors do
        for j = 1, 4 do
            __colors[i][j] = __colors[i][j] / 255
        end
    end

    __palette = {}
    for i = 0, 15 do
        __palette[i] = i
    end

    __current_color = 7
end

function cls(color)
    print(__colors[__palette[color]][1], __colors[__palette[color]][2], __colors[__palette[color]][3])
    love.graphics.clear(__colors[__palette[color]])
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
    r = r or 4
    if col then
        __current_color = col
    else
        col = __current_color
    end

    love.graphics.setColor(__colors[__palette[col]])
    love.graphics.circle("fill", x, y, r)
end
