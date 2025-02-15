function _init()
	t=0
end

function _update60()
	t=t+1/60
end

function _draw()
	cls()
	circfill(cos(t)*32+64,sin(t)*32+64)
end