--[[
    # Graphics: palette
    [] pal
    [] palt
    [x] color
]]

local bit = require "bit"

function _init_graphics()
    -- Big thanks to Johan Peitz 
    __colors = {
        [0] = { 0, 0, 0, 255 },
        -- [1] = { 29, 43, 83, 255 },
        [1] = { 0x11, 0x1d, 0x35, 255 }, -- Darker blue from alternate palette
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

        [128] = {0x29, 0x18, 0x14, 1},
        [129] = {0x11, 0x1d, 0x35, 1},
        [130] = {0x42, 0x21, 0x36, 1},
        [131] = {0x12, 0x53, 0x59, 1},
        [132] = {0x74, 0x2f, 0x29, 1},
        [133] = {0x49, 0x33, 0x3b, 1},
        [134] = {0xa2, 0x88, 0x79, 1},
        [135] = {0xf3, 0xef, 0x7d, 1},
        [136] = {0xbe, 0x12, 0x50, 1},
        [137] = {0xff, 0x6c, 0x24, 1},
        [138] = {0xa8, 0xe7, 0x2e, 1},
        [139] = {0x00, 0xb5, 0x43, 1},
        [140] = {0x06, 0x5a, 0xb5, 1},
        [141] = {0x75, 0x46, 0x65, 1},
        [142] = {0xff, 0x6e, 0x59, 1},
        [143] = {0xff, 0x9d, 0x81, 1},
    }

    for i = 0, #__colors do
        for j = 1, 4 do
            __colors[i][j] = __colors[i][j] / 255
        end
    end

    __palette = {}
    for i = 0, 15 do
        __palette[i+1] = i
    end

    __current_color = 7

    __shader_pico8_draw = love.graphics.newShader([[
        uniform int transparencyMask;
        uniform bool transparencyEnabled;
        uniform int palette[16];

        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            vec4 pixel = Texel(texture, texture_coords)*color;
            int index = int(pixel.r * 255);
            int x = transparencyMask;
            if (transparencyEnabled && ((1 << index) & transparencyMask) != 0) {
                return vec4(1, 1, 1, 0);
            }
            
            if (index >= 16 || index < 0) {
                return vec4(0, 0, 0, 1);
            }
            int test = palette[index];
            return vec4(palette[index] / 255.0, 0, 0, pixel.a);
        }
    ]])

    __shader_index_to_color = love.graphics.newShader([[
        uniform vec4 colors[16];
        uniform int palette[16];

        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            vec4 pixel = Texel(texture, texture_coords);
            int index = int(pixel.r * 255);
            if (index >= 16 || index < 0) {
                return vec4(0, 0, 0, 1);
            }
            return colors[ palette[index] ];
        }
    ]])

    __shader_color_to_index = love.graphics.newShader([[
        extern vec4 colors[16];

        float colorDist(vec4 colA, vec4 colB) {
            return pow(colA.r-colB.r,2) + pow(colA.g-colB.g,2) + pow(colA.b-colB.b,2);
        }

        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            vec4 pixel = Texel(texture, texture_coords);

            int bestIndex = 0;
            float bestDistance = 4294967296.0; // Just an arbitrary big constant (256^4)

            for (int i = 0; i < 16; i++) {
                float dist = colorDist(colors[i], pixel);
                if (dist < bestDistance) {
                    bestDistance = dist;
                    bestIndex = i;
                }
            }

            return vec4(bestIndex/255.0, 0, 0, 1);
        }
    ]])

    local colors_indexed = {}
    for i = 0, 15 do 
        local col = __colors[i]
        table.insert(colors_indexed, col)
    end

    __transparency_mask = 1 

    -- Shader stuff
    __shader_pico8_draw:send("transparencyMask", __transparency_mask)
    __shader_pico8_draw:send("transparencyEnabled", true)
    __shader_pico8_draw:send("palette", unpack(__palette))

    __shader_index_to_color:send("colors", unpack(colors_indexed))
    __shader_index_to_color:send("palette", unpack(__palette))

    __shader_color_to_index:send("colors", unpack(colors_indexed))

    __shader_is_active = false

    __spritesheet_source = love.graphics.newImage("game/assets/spritesheet.png")
    __spritesheet = love.graphics.newCanvas(__spritesheet_source:getWidth(), __spritesheet_source:getHeight(), {dpiscale = 1})
    love.graphics.setCanvas(__spritesheet)
    love.graphics.setShader(__shader_color_to_index)
    love.graphics.draw(__spritesheet_source, 0, 0)
    love.graphics.setShader()
    love.graphics.setCanvas()
end


function pal(a, b, flag)
    flag = flag or 0
    if a == nil then
        -- restore palette
        for i = 0, 15 do
            __palette[i+1] = i
        end
        palt()

    elseif type(a) == "table" then
        -- replace entire target palette
        for k, v in pairs(a) do
            pal((k % 16), v)
        end
    elseif type(a) == "number" and type(b) == "number" then
        -- replace single color
        __palette[a+1] = b
    else
        return
    end

    __shader_pico8_draw:send("palette", unpack(__palette))
    __shader_index_to_color:send("palette", unpack(__palette))
    if flag == 1 then
        -- 1 to modify the palette for the screen already drawn
        -- TODO
        -- local old_canvas = love.graphics.getCanvas()
        -- local old_color = {love.graphics.getColor()}
        -- love.graphics.setColor(1, 1, 1, 1) 
        -- love.graphics.setCanvas(__canvas)
        -- love.graphics.setShader(__shader_index_to_color)
        -- love.graphics.draw(__canvas, 0, 0)
        -- love.graphics.setShader()
        -- love.graphics.setColor(old_color) 
        -- love.graphics.setCanvas(old_canvas) 
    end
end


function palt(col, t)
    if col == nil then
        __transparency_mask = 1

    elseif t == nil then
        -- NOT SUPPORTED
        -- If called with only one argument, the transparency settings of all 
        -- colors are specified simultaneously using a single 16-bit field, with 
        -- set bits specifying transparent, and cleared bits specifying opaque. 
        -- Bit 0 (value 1) is for color 15, bit 1 (value 2) for color 14, and so on, down to color 0. 
    else
        if t then
            __transparency_mask = bit.bor(__transparency_mask, bit.lshift(1, col))
        else
            __transparency_mask = bit.band(__transparency_mask, bit.bnot(bit.lshift(1, col)))
        end
    end
    __shader_pico8_draw:send("transparencyMask", __transparency_mask)
end

function color(n)
    __current_color = n
end