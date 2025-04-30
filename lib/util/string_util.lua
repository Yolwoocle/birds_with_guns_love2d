
function copy_table_deep(orig)
	-- http://lua-users.org/wiki/CopyTable
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[copy_table_deep(orig_key)] = copy_table_deep(orig_value)
		end
		setmetatable(copy, copy_table_deep(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

function copy_table_shallow(tab)
	local ntab = {}

	for k, v in pairs(tab) do
		ntab[k] = v
	end
	return ntab
end


--- func desc
---@param node table
---@return string
function table_to_str(node)
	if node == nil then
		return "[nil]"
	end
	if type(node) ~= "table" then
		return "[print_table: not a table]"
	end

	-- https://www.grepper.com/answers/167958/print+table+lua?ucard=1
	local cache, stack, output = {}, {}, {}
	local depth = 1
	local output_str = "{\n"

	while true do
		local size = 0
		for k, v in pairs(node) do
			size = size + 1
		end

		local cur_index = 1
		for k, v in pairs(node) do
			if (cache[node] == nil) or (cur_index >= cache[node]) then
				if (string.find(output_str, "}", output_str:len())) then
					output_str = output_str .. ",\n"
				elseif not (string.find(output_str, "\n", output_str:len())) then
					output_str = output_str .. "\n"
				end

				-- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
				table.insert(output, output_str)
				output_str = ""

				local key
				if (type(k) == "number" or type(k) == "boolean") then
					key = "[" .. tostring(k) .. "]"
				else
					key = "['" .. tostring(k) .. "']"
				end

				if (type(v) == "number" or type(v) == "boolean") then
					output_str = output_str .. string.rep('\t', depth) .. key .. " = " .. tostring(v)
				elseif (type(v) == "table") then
					output_str = output_str .. string.rep('\t', depth) .. key .. " = {\n"
					table.insert(stack, node)
					table.insert(stack, v)
					cache[node] = cur_index + 1
					break
				else
					output_str = output_str .. string.rep('\t', depth) .. key .. " = '" .. tostring(v) .. "'"
				end

				if (cur_index == size) then
					output_str = output_str .. "\n" .. string.rep('\t', depth - 1) .. "}"
				else
					output_str = output_str .. ","
				end
			else
				-- close the table
				if (cur_index == size) then
					output_str = output_str .. "\n" .. string.rep('\t', depth - 1) .. "}"
				end
			end

			cur_index = cur_index + 1
		end

		if (size == 0) then
			output_str = output_str .. "\n" .. string.rep('\t', depth - 1) .. "}"
		end

		if (#stack > 0) then
			node = stack[#stack]
			stack[#stack] = nil
			depth = cache[node] == nil and depth + 1 or depth - 1
		else
			break
		end
	end

	-- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
	table.insert(output, output_str)
	output_str = table.concat(output)

	return (output_str)
end

function print_table(node)
	print(table_to_str(node))
end