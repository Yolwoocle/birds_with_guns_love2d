require "pico8.constants"
require "pico8.string"
require "pico8.lang"
require "pico8.math"
require "pico8.meta"
require "pico8.palette"
require "pico8.sprite"
require "pico8.drawing"
require "pico8.input"
require "pico8.memory"
require "pico8.table"
require "pico8.map"
require "pico8.audio"
require "pico8.menus"
local Options = require "lib.options.options"

local pico8 = {}

local fixed_dt = 1 / 60 -- fixed frame delta time
local max_frame_buffer_duration = 1 / 15

local canvas_width = 128
local canvas_height = 128

local screenshot_scale = 3

function pico8.init()
    love.window.setMode(canvas_width, canvas_height, {
        fullscreen = false,
        resizable = true,
        -- vsync = Options:get("is_vsync"),
        minwidth = canvas_width,
        minheight = canvas_height,
    })
    love.window.maximize()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("rough")

    __debug_info = false

    __width = canvas_width
    __height = canvas_height

    __final_canvas = love.graphics.newCanvas(__width, __height, { dpiscale = 1 })
    __canvas = love.graphics.newCanvas(__width, __height, { dpiscale = 1 }) -- Game canvas
    __buffer_canvas = love.graphics.newCanvas(__width, __height, { dpiscale = 1 })
    __screenshot_buffer_canvas = love.graphics.newCanvas(__width * screenshot_scale, __height * screenshot_scale,
        { dpiscale = 1 })
    __accum_t = 0.0
    __accum_frame60 = 0

    __buffer_mouse_wheel_state = 0
    __mouse_wheel_state = 0

    __camera_x = 0
    __camera_y = 0

    _load_p8scii()
    __font_normal = love.graphics.newImageFont("pico8/assets/pico8_font.png", FONT_NORMAL_CHARSET)
    __font_simplified_chinese = love.graphics.newImageFont("pico8/assets/pico8_simplified_chinese_font.png", SIMPLIFIED_CHINESE_SYMBOLS)
    __font_japanese = love.graphics.newImageFont("pico8/assets/pico8_japanese_font.png", JAPANESE_SYMBOLS)
    __font_korean = love.graphics.newImageFont("pico8/assets/pico8_korean_font.png", KOREAN_SYMBOLS)

    __font_simplified_chinese:setFallbacks(__font_normal)
    __font_japanese:setFallbacks(__font_normal)
    __font_korean:setFallbacks(__font_normal)
    __fonts = {
        ["normal"] = __font_normal,
        ["simplified_chinese"] = __font_simplified_chinese,
        ["japanese"] = __font_japanese,
        ["korean"] = __font_korean,
    }

    local font_height_ratio = 6/__font_normal:getHeight()
    __font_normal:setLineHeight(font_height_ratio)
    __font_simplified_chinese:setLineHeight(font_height_ratio)
    __font_japanese:setLineHeight(font_height_ratio)
    __font_korean:setLineHeight(font_height_ratio)
    
    _init_pinball_font(font_height_ratio)

    __font = __font_normal

    __input_state = {}
    for btn_id, _ in pairs(BTN_MAP) do
        __input_state[btn_id] = 0
    end
    _reset_input_state()
    __standby_input_frames = 10

    _init_lang()
    _init_graphics()
    _load_sprite_flags()
    _init_map()
    _init_audio()
    _init_menus()

    pico8._init()

    
    local function wide(t, x, y, col, pre)
        --credit to yolwoocle uwu
        t1 =  "                ! #$%&'()  ,-./[12345[7[9:;<=>?([[c[efc[ij[l[[([([st[[[&yz[\\]'_`[[c[efc[ij[l[[([([st[[[&yz{|}~"
        t2 = "                !\"=$  '()*+,-./0123]5678]:;<=>?@abcdefghijklmnopqrstuvwx]z[\\]^_`abcdefghijklmnopqrstuvwx]z{|} "
        n1, n2 = "", ""
        pre = pre or ""

        for i = 1, #t do
            local char = sub(t, i, i)
            local c = ord(char) - 16
            n1 = n1 .. sub(t1, c, c) .. " "
            n2 = n2 .. sub(t2, c, c) .. " "
        end

        if (col ~= nil) then color(col) end
        print_(pre .. n1, x, y)
        print_(pre .. n2, x + 1, y)
    end

    local canvastmp = love.graphics.newCanvas(3000, __font:getHeight(), {dpiscale = 1})
    love.graphics.setCanvas(canvastmp)
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1, 1)
    for i=12,127 do
        local c = sub(P8SCII_SYMBOLS, i, i)
        if i <= 127 then
            wide(c, (i-1)*9, 0, 7)
        else
            print_(c, (i-1)*9, 0, 7)
        end
        line((i-1)*9-1, 0, (i-1)*9-1, 10, 15)
    end
    love.graphics.setCanvas()

    local imgdata, imgpng = _save_canvas_as_file(canvastmp, "fontlol.png")

    Options:update_options()
end

__init = function()
    pico8.init()
end

function pico8.update(dt)
    __accum_t = math.min(__accum_t + dt, max_frame_buffer_duration)
    local update_fixed_dt = fixed_dt
    if (__accum_t > update_fixed_dt) then
        __accum_t = __accum_t - update_fixed_dt

        pico8._engine_update(1 / 60, __accum_frame60 % 2 == 0)
        if not __paused then
            __reset_menus()
            pico8._update60()
            if __accum_frame60 % 2 == 0 then
                pico8._update()
            end
        else
            _update_menus(dt)
        end
        __accum_frame60 = __accum_frame60 + 1
    end

    pico8._update_screen()
end

function pico8.draw()
    love.graphics.setCanvas(__canvas)
    love.graphics.setShader(__shader_pico8_draw)
    love.graphics.origin()
    love.graphics.translate(-__camera_x, -__camera_y)
    if not __paused then
        pico8._draw()
    end
    pico8._draw_debug()

    pico8._draw_menu_layer()

    -- Render final canvas
    love.graphics.setShader()
    love.graphics.setCanvas()

    love.graphics.origin()
    love.graphics.scale(1, 1)
    local old_color = { love.graphics.getColor() }
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setShader(__shader_index_to_color)

    love.graphics.draw(__final_canvas, __canvas_ox, __canvas_oy, 0, __canvas_scale, __canvas_scale)

    love.graphics.setShader()
    love.graphics.setColor(old_color)

    __final_canvas:renderTo(function()
        love.graphics.clear()
    end)
end

function pico8._draw_menu_layer()
    love.graphics.setCanvas(__final_canvas)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(__canvas, 0, 0)

    _set_love_color(__current_color)

    _draw_menus()
end

function pico8._draw_debug()
    love.graphics.origin()
    if __debug_info then
        rectfill(0, 0, 32, 16, 0)
        print_(tostring(love.timer.getFPS()) .. "FPS", 0, 0, 7)
        print_(__input_state[BTN_PAUSE], 0, 0 + 6 * 1, 7)
        print_(pico8._is_btn_down(BTN_PAUSE), 0, 0 + 6 * 2, 7)
        print_(btn(BTN_PAUSE), 0, 0 + 6 * 3, 7)
    end
end

-- Utils

function pico8.wheelmoved(x, y)
    __buffer_mouse_wheel_state = mid(round(y), 1, -1)
end

function pico8._engine_update(dt, is_30fps_frame)
    if __standby_input_frames <= 0 then
        pico8._update_input_state()
    end
    __standby_input_frames = __standby_input_frames - 1

    __mouse_wheel_state = __buffer_mouse_wheel_state
    __buffer_mouse_wheel_state = 0

    if btnp(BTN_PAUSE) then
        _toggle_pause()
    end
    if not __paused then
        _update_meta(dt)
    end
end

function pico8._is_btn_down(btn_id)
    local keys = BTN_MAP[btn_id]
    if not keys then
        return false
    end

    for _, key in pairs(keys) do
        if love.keyboard.isScancodeDown(key) then
            return true
        end
    end
    return false
end

function pico8._update_input_state()
    for btn_id, _ in pairs(BTN_MAP) do
        local pressed = pico8._is_btn_down(btn_id)
        local old_state = __input_state[btn_id]
        if old_state ~= nil then
            if pressed then
                if old_state == INPUT_STATE_OFF or old_state == INPUT_STATE_RELEASING then
                    __input_state[btn_id] = INPUT_STATE_PRESSING
                elseif old_state == INPUT_STATE_PRESSING then
                    __input_state[btn_id] = INPUT_STATE_ON
                end
            else
                if old_state == INPUT_STATE_RELEASING then
                    __input_state[btn_id] = INPUT_STATE_OFF
                elseif old_state == INPUT_STATE_ON or old_state == INPUT_STATE_PRESSING then
                    __input_state[btn_id] = INPUT_STATE_RELEASING
                end
            end
        end
    end
end

function pico8._update_screen()
    __window_width, __window_height = love.graphics.getDimensions()

    local pixel_scale_mode = "max_whole" --Options:get("pixel_scale")

    local screen_sx = __window_width / canvas_width
    local screen_sy = __window_height / canvas_height
    local auto_scale = math.min(screen_sx, screen_sy)

    local scale = auto_scale

    if pixel_scale_mode == "auto" then
        scale = auto_scale
    elseif pixel_scale_mode == "max_whole" then
        scale = math.max(1, math.floor(auto_scale))
    elseif type(tonumber(pixel_scale_mode)) == "number" then
        scale = math.min(tonumber(pixel_scale_mode), auto_scale)
    else
        print("update_screen: WARNING: pixel scale mode has invalid value: '" .. tostring(pixel_scale_mode) .. "'")
    end

    __canvas_scale = scale

    __canvas_ox = math.floor(max(0, (__window_width - canvas_width * __canvas_scale) / 2))
    __canvas_oy = math.floor(max(0, (__window_height - canvas_height * __canvas_scale) / 2))
end

function _save_canvas_as_file(canvas, filename)
    local imgdata = love.graphics.readbackTexture(canvas)
    local imgpng = imgdata:encode("png", filename)

    return imgdata, imgpng
end

function pico8.screenshot()
    local filename = os.date('pico8_%Y-%m-%d_%H-%M-%S.png')
    local old_color = { love.graphics.getColor() }
    local old_shader = love.graphics.getShader()

    love.graphics.setCanvas(__screenshot_buffer_canvas)
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setShader(__shader_index_to_color)
    love.graphics.draw(__canvas, 0, 0, 0, screenshot_scale)
    love.graphics.setCanvas()

    local imgdata, imgpng = _save_canvas_as_file(__screenshot_buffer_canvas, filename)
    local filepath = love.filesystem.getSaveDirectory() .. "/" .. filename

    love.graphics.setShader(old_shader)
    love.graphics.setColor(old_color)

    return filename, filepath, imgdata, imgpng
end

function pico8.keypressed(key, scancode, isrepeat)
    if key == "f1" then
        pico8.screenshot()
    elseif key == "f3" then
        __debug_info = not __debug_info
    elseif key == "r" and love.keyboard.isDown("lctrl", "rctrl") then
        run()
    end
end

-- CALLBACKS

function pico8._init()
end

function pico8._update()
end

function pico8._update60()
end

function pico8._draw()
end

return pico8

--[[
    # Engine
    [ ] run
    [x] time
    [x] t (== time)
    [ ] menuitem
    [ ] printh
    [ ] _init
    [ ] _update
    [ ] _update60
    [ ] _draw

    # Graphics
    [ ] pal
    [ ] palt
    [ ] camera
    [x] cls
    [ ] map
    [x] spr
    [x] print
    [x] line
    [x] rectfill
    [x] rect
    [x] circ
    [x] circfill
    [x] color

    # Memory
    [ ] poke
    [ ] peek
    [ ] stat
    [ ] mset
    [ ] mget
    [ ] fget
    [ ] fset

    # Table
    [x] add
    [x] del
    [x] all
    [x] unpack

    # String
    [x] ord
    [x] chr
    [x] sub
    [x] split
    [x] tostr
    [x] tonum

    # Math
    [x] min
    [x] max
    [x] mid
    [x] rnd
    [x] flr
    [x] ceil
    [x] sqrt
    [x] abs
    [x] atan2
    [x] cos
    [x] sin

    # Input
    [ ] btn
    [ ] btnp

    # Audio
    [ ] music
    [ ] sfx

    # Other
    [x] +=, -=, ...
    [x] if()
    [x] if ...do without space
    [x] 🅾️, ❎...
    [x] \
    [ ] &
    [ ] &~ (???)
]]
