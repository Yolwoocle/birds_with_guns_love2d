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

function contains(element, table)
	for k, v in pairs(table) do
		if v == element then
			return true, k
		end
	end
	return false
end

function concat(...)
	local args = { ... }
	for i = 1, #args do
		local val = args[i]
		local val_str = tostring(val)
		if type(val) == "nil" then
			val_str = "nil"
			-- elseif type(val) == "table" then
			-- 	val_str = table_to_str(val)
		end

		args[i] = val_str
	end
	return table.concat(args)
end

function strtobool(str)
	return str ~= "false" -- Anything other than "false" returns as true
end

function split_str(inputstr, sep, include_empty)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	local pattern = "([^" .. sep .. "]+)"
	if include_empty then
		pattern = pattern .. "()"
	end

	local last_pos = 1

	for str, pos in string.gmatch(inputstr, pattern) do
		table.insert(t, str)
		last_pos = pos
	end

	if include_empty and last_pos <= #inputstr then
		table.insert(t, "")
	end

	return t
end

function concatsep(tab, sep)
	sep = sep or " "
	local s = tostring(tab[1] or "")
	for i = 2, #tab do
		s = s .. sep .. tostring(tab[i])
	end
	return s
end
