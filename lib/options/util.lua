local util = {}

function util.strtobool(str)
	return str ~= "false" -- Anything other than "false" returns as true
end

function util.concat(...)
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


function util.split_str(inputstr, sep, include_empty)
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


return util