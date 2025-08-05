require "lib.util.string_util"
require "lib.util.math_util"

function math.round(num, num_dec)
	-- http://lua-users.org/wiki/SimpleRound
	local mult = 10 ^ (num_dec or 0)
	return math.floor(num * mult + 0.5) / mult
end

function param(value, def_value)
	if value == nil then
		return def_value
	end
	return value
end

function repeat_string(string, amount)
	local s = ""
	for i=1, amount do
		s = s..string
	end
	return s
end