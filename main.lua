require "lib.error_explorer" {
	source_font = love.graphics.newFont("fonts/FiraCode-Regular.ttf", 12)
}
require "game.game"
local pico8 = require "pico8"
local test = require "pico8.test"


function love.load()
    pico8.init()
end

function love.update(dt)
    pico8.update(dt)
end

function love.draw()
    pico8.draw()
end

function love.keypressed(key, scancode, isrepeat)
    pico8.keypressed(key, scancode, isrepeat)
end

function love.wheelmoved(x, y)
    pico8.wheelmoved(x, y)
end

