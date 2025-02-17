require "pico8.constants"
require "pico8.string"
require "pico8.math"
require "pico8.palette"
require "pico8.drawing"

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

    __width = canvas_width
    __height = canvas_height

    __canvas = love.graphics.newCanvas(__width, __height, {dpiscale = 1})
    __buffer_canvas = love.graphics.newCanvas(__width, __height, {dpiscale = 1})
    __accum_t = 0.0
    __accum_frame60 = 0

    __font = love.graphics.newImageFont("pico8/pico8_font.png", FONT_SYMBOLS)

    _init_graphics()
    pico8._init()
end

function pico8.update(dt)
	__accum_t = math.min(__accum_t + dt, max_frame_buffer_duration)
	local update_fixed_dt = fixed_dt
	if (__accum_t > update_fixed_dt) then
		__accum_t = __accum_t - update_fixed_dt
		pico8._update60()
        if __accum_frame60 % 2 == 0 then
            pico8._update()
        end
        __accum_frame60 = __accum_frame60 + 1
	end

    pico8.update_screen()
end

function pico8.draw()
    love.graphics.setCanvas(__canvas)
    pico8._draw()
    love.graphics.setCanvas()
    
    love.graphics.origin()
	love.graphics.scale(1, 1)
    love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(__canvas, __canvas_ox, __canvas_oy, 0, __canvas_scale, __canvas_scale)
end

-- Utils 

function pico8.update_screen()
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



local function save_canvas_as_file(canvas, filename, encoding_format)
	local imgdata = canvas:newImageData()
	local imgpng = imgdata:encode("png", filename)

	return imgdata, imgpng
end

function pico8.screenshot()
    local filename = os.date('pico8_%Y-%m-%d_%H-%M-%S.png') 
	
	love.graphics.setCanvas(__buffer_canvas)
	love.graphics.clear()
	love.graphics.draw(__canvas, 0, 0, 0, screenshot_scale)
	love.graphics.setCanvas()
	
	local imgdata, imgpng = save_canvas_as_file(__buffer_canvas, filename, "png")
	local filepath = love.filesystem.getSaveDirectory().."/"..filename

	return filename, filepath, imgdata, imgpng
end

function pico8.keypressed(key, scancode, isrepeat)
    if key == "f1" then
        pico8.screenshot()
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
    [ ] time
    [ ] t (== time)
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
    [ ] cls
    [ ] map
    [ ] spr
    [ ] print
    [ ] line
    [ ] rectfill
    [ ] rect
    [ ] circ
    [ ] circfill
    [ ] color

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
    [ ] tonum

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