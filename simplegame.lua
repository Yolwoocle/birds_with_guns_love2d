function _init()
	t=0
end

function _update60()
	t=t+1/60
end

function _draw()
	cls()
	-- circfill(cos(t)*32+64,sin(t)*32+64)
	circfill(5, 64, 1)
	circfill(10, 64, 2)
	circfill(15, 64, 3)
	circfill(20, 64, 4)
	circfill(20, 64, 5)
	circfill(25, 64, 6)
	circfill(30, 64, 7)
end