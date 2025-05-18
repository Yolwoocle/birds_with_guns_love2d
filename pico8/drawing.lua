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

function _init_pinball_font(font_height_ratio)
    local img = love.graphics.newImage("pico8/assets/pico8_font.png")
    local img_data = love.graphics.readbackTexture(img)
    local img_pinball = love.graphics.newCanvas(img:getWidth() * 2, img:getHeight() * 2, { dpiscale = 1 })
    love.graphics.setCanvas(img_pinball) 

    for ix = 0, img:getWidth() - 1 do
        for iy = 0, img:getHeight() - 1 do
            local pixel = { img_data:getPixel(ix, iy) }
            love.graphics.setColor(pixel)
            if iy == 0 and (pixel[1] > 0.8) and (pixel[2] == 0) and (pixel[3] == 0) then
                love.graphics.rectangle("fill", ix * 2, 0, 2, img:getHeight() * 2)
            else
                love.graphics.rectangle("fill", ix * 2, iy * 2, 1, 1)
            end
        end
    end
    love.graphics.setCanvas()

    __font_pinball = love.graphics.newImageFont(love.graphics.readbackTexture(img_pinball), P8SCII_SYMBOLS)
    __font_pinball:setLineHeight(font_height_ratio)
end

function _set_love_color(col)
    love.graphics.setColor(col/255, 0, 0, 1)
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

function darkrect(px1, py1, px2, py2)
    local x = flr(min(px1, px2))
    local y = flr(min(py1, py2))
    local w = abs(px1 - px2) +1
    local h = abs(py1 - py2) +1

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setShader()
    __buffer_canvas:renderTo(function()
        love.graphics.clear(0,0,0,0)
        love.graphics.draw(__canvas, 0, 0)
    end)
    love.graphics.setShader(__shader_pico8_draw)

    love.graphics.setScissor(x, y, w, h)
    
    local buffpal = copy_table_deep(__palette)
    
    __shader_pico8_draw:send("transparencyEnabled", false)
    pal({ [0]=0, 0, 0, 1,  1, 1, 1, 1,  1, 1, 1, 1,  1, 1, 1, 1})
    __shader_pico8_draw:send("transparencyMask", 0)
    love.graphics.draw(__buffer_canvas, 0, 0)
    __shader_pico8_draw:send("transparencyEnabled", true)

    __palette = buffpal
    _apply_palette()

    __shader_pico8_draw:send("transparencyMask", __transparency_mask)
    _set_love_color(__current_color)
    love.graphics.setScissor()
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
    local y0 = flr(_y) - 4

    if col then
        __current_color = col
    else
        col = __current_color
    end

    _set_love_color(col)
    love.graphics.setFont(__font)
    __shader_pico8_draw:send("transparencyEnabled", false)
    love.graphics.print(_parse_text(_str), flr(x0), flr(y0))
    __shader_pico8_draw:send("transparencyEnabled", true)
end

function print_pinball(_str, _x, _y, col)
    local old_font = __font
    __font = __font_pinball
    
    print_(_str, _x, _y - 4, col)
    
    __font = old_font
end