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
	-- pal(8,9)
	spr(1,64,64,2,2)
	pal()

	for i=0, 15 do
		rectfill(i*4, 42, i*4+4, 42+4, i)
	end

	-- cls(1)

	-- spr(0, 0, 0, 10, 10)
	-- print_(tostr(tim), 70, 70)
	-- pal(8, 9)
	-- circfill(stat(32), stat(33), 16, 15)
	-- print(
	-- 	tostr(bit.band(stat(34), 4)) .. tostr(bit.band(stat(34), 2)) .. tostr(bit.band(stat(34), 1)), 
	-- 	stat(32), stat(33), 8)


	-- print(
	-- 	tostr(math.min(1, bit.band(btnp(), bit.lshift(1, 13)))) .. 
	-- 	tostr(math.min(1, bit.band(btnp(), bit.lshift(1, 12)))) .. 
	-- 	tostr(math.min(1, bit.band(btnp(), bit.lshift(1, 11)))) .. 
	-- 	tostr(math.min(1, bit.band(btnp(), bit.lshift(1, 10)))) .. 
	-- 	tostr(math.min(1, bit.band(btnp(), bit.lshift(1, 9)))) .. 
	-- 	tostr(math.min(1, bit.band(btnp(), bit.lshift(1, 8)))) .. 
	-- 	tostr(math.min(1, bit.band(btnp(), bit.lshift(1, 7)))) .. 
	-- 	tostr(math.min(1, bit.band(btnp(), bit.lshift(1, 6)))) .. 
	-- 	tostr(math.min(1, bit.band(btnp(), bit.lshift(1, 5)))) .. 
	-- 	tostr(math.min(1, bit.band(btnp(), bit.lshift(1, 4)))) .. 
	-- 	tostr(math.min(1, bit.band(btnp(), bit.lshift(1, 3)))) .. 
	-- 	tostr(math.min(1, bit.band(btnp(), bit.lshift(1, 2)))) .. 
	-- 	tostr(math.min(1, bit.band(btnp(), bit.lshift(1, 1)))) .. 
	-- 	tostr(math.min(1, bit.band(btnp(), bit.lshift(1, 0)))),
	-- 	stat(32), stat(33) + 8, 8)
end