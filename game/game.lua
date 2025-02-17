local pico8 = require "pico8"

function pico8._init()
	t=0
end

function pico8._update60()
	t=t+1/60
end

function pico8._draw()
	cls(1)
	-- circfill(cos(t)*32+64,sin(t)*32+64)
	circfill(5,  64, 1, 7)
	circfill(15, 64, 2, 7)
	circfill(30, 64, 3, 7)
	circfill(45, 64, 4, 7)
	circfill(60, 64, 5, 7)
	circfill(75, 64, 6, 7)
	circfill(90, 64, 7, 7)

	-- rect(1, 1, 5, 5, 10)
	-- rect(1, 1, 4, 4, 9)
	-- rect(1, 1, 3, 3, 8)
	rect(1, 1, 126, 126, 12)
	rect(1, 1, 16, 16, 11)

	rectfill(1, 1, 5, 5, 10)
	rectfill(1, 1, 4, 4, 9)
	rectfill(1, 1, 3, 3, 8)

	for i=0, 127 do
		pset(i, i, 7)
	end

	pprint("hello█▒⬅️", 64, 110, 8)
end