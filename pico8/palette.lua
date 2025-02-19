--[[
    # Graphics: palette
    [] pal
    [] palt
    [x] color
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

    __palette_swap = [[
        extern vec3 palette[32];
        extern int palSwaps[32];

        // calculate how "similar" two colours are
        // currently just does this by snapping rgb values- would like to eventually swap this to hsv or some equiv.
        float deltaE(vec3 colA, vec3 colB) {
            return sqrt(pow(colA.r-colB.r,2)+pow(colA.g-colB.g,2)+pow(colA.b-colB.b,2));
        }
        
        vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
            vec4 pixel = Texel(texture, texture_coords);

            float thresh = 0.05;        // how close the colour has to be , could probably be arbitrarily small -ish
            for(int i=0; i<32; i++){
                if (palSwaps[i]!=i && deltaE( pixel.rgb, palette[i] )<thresh) {
                    return vec4(palette[ palSwaps[i] ].rgb, color.a);
                }
            }

            return pixel * color;
        }
    ]]
end


function pal(...)
    -- TODO
end

function palt(...)
    -- TODO
end

function color(n)
    __current_color = n
end