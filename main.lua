local pico8 = require "pico8"
local test = require "pico8.test"
require "game.game"

function love.load()
    pico8.init()
end

function love.update(dt)
    pico8.update(dt)
end

function love.draw()
    pico8.draw()
end