require "pico8.constants"
require "pico8.string"
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

local pico8 = {}

local fixed_dt = 1/60 -- fixed frame delta time
local max_frame_buffer_duration = 1/15

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

    __canvas = love.graphics.newCanvas(__width, __height, {dpiscale = 1})
    __buffer_canvas = love.graphics.newCanvas(__width, __height, {dpiscale = 1})
    __accum_t = 0.0
    __accum_frame60 = 0

    __buffer_mouse_wheel_state = 0
    __mouse_wheel_state = 0

    __camera_x = 0
    __camera_y = 0

    __font_normal = love.graphics.newImageFont("game/assets/pico8_font.png", FONT_SYMBOLS)

    ---[[[[]]]]
    local img = love.graphics.newImage("game/assets/pico8_font.png")
    local img_data = love.graphics.readbackTexture(img)
    local img_pinball = love.graphics.newCanvas(img:getWidth()*2, img:getHeight()*2, {dpiscale = 1})
    love.graphics.setCanvas(img_pinball)
    
    for ix=0, img:getWidth()-1 do
        for iy=0, img:getHeight()-1 do
            local pixel = {img_data:getPixel(ix, iy)}
            love.graphics.setColor(pixel)
            if iy == 0 and (pixel[1] > 0.8) and (pixel[2] == 0) and (pixel[3] == 0) then
                love.graphics.rectangle("fill", ix*2, 0, 2, img:getHeight()*2)
            else
                love.graphics.rectangle("fill", ix*2, iy*2, 1, 1)
            end
        end
    end
    love.graphics.setCanvas()
    _save_canvas_as_file(img_pinball, "testtest.png")

    __font_pinball = love.graphics.newImageFont(love.graphics.readbackTexture(img_pinball), FONT_SYMBOLS)
    ---[[[[]]]]
    __font = __font_normal

    __input_state = {}
    for btn_id, _ in pairs(BTN_MAP) do
        __input_state[btn_id] = 0
    end
    for ip = 0, MAX_PLAYERS-1 do
        for ib = 0, BTN_COUNT-1 do
            __input_state[ip*BTN_COUNT + ib] = 0
        end
    end

    _init_graphics()
    _load_sprite_flags()
    _init_map()

    pico8._init()
end

function pico8.update(dt)
	__accum_t = math.min(__accum_t + dt, max_frame_buffer_duration)
	local update_fixed_dt = fixed_dt
	if (__accum_t > update_fixed_dt) then
		__accum_t = __accum_t - update_fixed_dt

        pico8._run_frame(__accum_frame60 % 2 == 0)
		pico8._update60()
        if __accum_frame60 % 2 == 0 then
            pico8._update()
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
    pico8._draw()
    pico8._draw_debug()    
    love.graphics.setCanvas()
    
    love.graphics.origin()
	love.graphics.scale(1, 1)
    local old_color = {love.graphics.getColor()}
    love.graphics.setColor(1, 1, 1, 1) 
    love.graphics.setShader(__shader_index_to_color)
	love.graphics.draw(__canvas, __canvas_ox, __canvas_oy, 0, __canvas_scale, __canvas_scale)
    love.graphics.setShader()
    love.graphics.setColor(old_color) 
end

function pico8._draw_debug()
    love.graphics.origin()
    if __debug_info then
        rectfill(0, 0, 32, 16, 0)
        print(tostring(love.timer.getFPS()).."FPS", 0, 0, 7)
    end 
end

-- Utils 

function pico8.wheelmoved(x, y)
    __buffer_mouse_wheel_state = mid(round(y), 1, -1)
end

function pico8._run_frame(is_30fps_frame)
    __mouse_wheel_state = __buffer_mouse_wheel_state
    __buffer_mouse_wheel_state = 0
    
    pico8._update_input_state()
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

	local pixel_scale_mode = "max_whole"--Options:get("pixel_scale")

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
	
	love.graphics.setCanvas(__buffer_canvas)
	love.graphics.clear()
	love.graphics.draw(__canvas, 0, 0, 0, screenshot_scale)
	love.graphics.setCanvas()
	
	local imgdata, imgpng = save_canvas_as_file(__buffer_canvas, filename)
	local filepath = love.filesystem.getSaveDirectory().."/"..filename

	return filename, filepath, imgdata, imgpng
end

function pico8.keypressed(key, scancode, isrepeat)
    if key == "f1" then
        pico8.screenshot()
    elseif key == "f3" then
        __debug_info = not __debug_info
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