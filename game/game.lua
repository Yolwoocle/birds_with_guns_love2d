local pico8 = require "pico8"

function pico8._init()
	t=0
end

function pico8._update60()
	t=t+1/300
end

function pico8._draw()
	cls(2)
	circfill(cos(t)*32+64,sin(t)*32+64, 8, 10)
end