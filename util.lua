require "lib.util.string_util"
require "lib.util.math_util"

function param(value, def_value)
	if value == nil then
		return def_value
	end
	return value
end
