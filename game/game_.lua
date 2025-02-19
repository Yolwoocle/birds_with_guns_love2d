local pico8 = require "pico8"
local bit = require("bit")

function pico8._init()
	tim=0
end

function pico8._update60()
	tim=tim+1/60
end

function pico8._draw()
	cls(1)
	-- circfill(cos(t)*32+64,sin(t)*32+64)
	circfill(5,  64, 1, 7)
	circfill(15, 64, 2, 7)

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

	print("█▒⬅️rロッャュョ◜◝", 2, 110, 8)

	spr(1, 30, 64, 2, 2, (tim % 1 < 0.5))
	
	pset(stat(32), stat(33), 8)
	print(
		tostr(bit.band(stat(34), 4)) .. tostr(bit.band(stat(34), 2)) .. tostr(bit.band(stat(34), 1)), 
		stat(32), stat(33), 8)

		
	local iy = 0
	for btn_id, _ in pairs(BTN_MAP) do
		print(btn_id .. " " .. tostr(btn(btn_id)) .. " " .. tostr(btnp(btn_id)), 70, iy, 10)
		iy = iy + 6
	end
end