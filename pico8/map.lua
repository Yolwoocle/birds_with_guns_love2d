function _convert_p8_map()
    -- load original tile map
    local data = love.filesystem.read("game/assets/map.txt")
    assert(data, "No map.txt file found.")
    local lines = split(data, "\n", false)
    local s = ""
    for y = 1, 64 do
        for x = 0, 255, 2 do
            local c = sub(lines[y], x + 1, x + 2)
            if y > 32 then
                c = sub(c,2,2) .. sub(c,1,1)
            end
            local n = tonumber(c, 16)
            mset(x / 2, y - 1, n)
            s = s..c.." "
        end
        s = s.."\n\n"
    end
end

function _init_map()
    __map_width = 128
    __map_height = 64
    __map = {}
    for ix = 0, __map_width-1 do
        __map[ix] = {}
        for iy = 0, __map_height-1 do
            __map[ix][iy] = 0
        end
    end

    _convert_p8_map()
    print('map', mget(1, 13))
end

function _in_bounds(x, y)
    return 0 <= x and x < __map_width and 0 <= y and y < __map_height
end

function mset(ix, iy, tile)
    if not _in_bounds(ix, iy) then
        return
    end
    __map[ix][iy] = tile
end

function mget(ix, iy)
    if not _in_bounds(ix, iy) then
        return 0
    end
    return __map[ix][iy]
end

-- NOT IMPLEMENTED: flags
function map(celx, cely, sx, sy, celw, celh, flags)
    celx = celx or 0
    cely = cely or 0
    sx = sx or 0
    sy = sy or 0
    celw = celw or __map_width 
    celh = celh or __map_height
    flags = flags or 0
    
    for dx = 0, celw-1 do
        for dy = 0, celh-1 do
            local ix, iy = celx + dx, cely + dy
            spr(mget(ix, iy), sx + dx*8, sy + dy*8)
        end
    end
end
