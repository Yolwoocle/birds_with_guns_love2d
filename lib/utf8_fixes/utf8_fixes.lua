local utf8 = require "utf8"
local t = require "lib.utf8_fixes.utf8_data"
local utf8_lc_uc, utf8_uc_lc = t[1], t[2]

-- Thanks to "index five" on Discord
local utf8pos, utf8len = utf8.offset, utf8.len
local sub = string.sub
local max, min = math.max, math.min

local new_utf8 = {}
for k, v in pairs(utf8) do
	new_utf8[k] = v
end

local function posrelat(pos, len)
	if pos >= 0 then return pos end
	if -pos > len then return 0 end
	return pos + len + 1
end

function new_utf8.sub(str, i, j)
	local len = utf8len(str)
	i, j = max(posrelat(i, len), 1), j and min(posrelat(j, len), len) or len
	if i <= j then
		return sub(str, utf8pos(str, i), utf8pos(str, j + 1) - 1)
	end
	return ""
end


-- Taken from https://github.com/Stepets/utf8.lua
-- The MIT License (MIT)

-- Copyright (c) 2016 Stepets

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.


-- returns the number of bytes used by the UTF-8 character at byte i in s
-- also doubles as a UTF-8 character validator
local function utf8charbytes (s, i)
	-- argument defaults
	i = i or 1

	-- argument checking
	if type(s) ~= "string" then
		error("bad argument #1 to 'utf8charbytes' (string expected, got ".. type(s).. ")")
	end
	if type(i) ~= "number" then
		error("bad argument #2 to 'utf8charbytes' (number expected, got ".. type(i).. ")")
	end

	local c = string.byte(s, i)

	-- determine bytes needed for character, based on RFC 3629
	-- validate byte 1
	if c > 0 and c <= 127 then
		-- UTF8-1
		return 1

	elseif c >= 194 and c <= 223 then
		-- UTF8-2
		local c2 = string.byte(s, i + 1)

		if not c2 then
			error("UTF-8 string terminated early")
		end

		-- validate byte 2
		if c2 < 128 or c2 > 191 then
			error("Invalid UTF-8 character")
		end

		return 2

	elseif c >= 224 and c <= 239 then
		-- UTF8-3
		local c2 = string.byte(s, i + 1)
		local c3 = string.byte(s, i + 2)

		if not c2 or not c3 then
			error("UTF-8 string terminated early")
		end

		-- validate byte 2
		if c == 224 and (c2 < 160 or c2 > 191) then
			error("Invalid UTF-8 character")
		elseif c == 237 and (c2 < 128 or c2 > 159) then
			error("Invalid UTF-8 character")
		elseif c2 < 128 or c2 > 191 then
			error("Invalid UTF-8 character")
		end

		-- validate byte 3
		if c3 < 128 or c3 > 191 then
			error("Invalid UTF-8 character")
		end

		return 3

	elseif c >= 240 and c <= 244 then
		-- UTF8-4
		local c2 = string.byte(s, i + 1)
		local c3 = string.byte(s, i + 2)
		local c4 = string.byte(s, i + 3)

		if not c2 or not c3 or not c4 then
			error("UTF-8 string terminated early")
		end

		-- validate byte 2
		if c == 240 and (c2 < 144 or c2 > 191) then
			error("Invalid UTF-8 character")
		elseif c == 244 and (c2 < 128 or c2 > 143) then
			error("Invalid UTF-8 character")
		elseif c2 < 128 or c2 > 191 then
			error("Invalid UTF-8 character")
		end

		-- validate byte 3
		if c3 < 128 or c3 > 191 then
			error("Invalid UTF-8 character")
		end

		-- validate byte 4
		if c4 < 128 or c4 > 191 then
			error("Invalid UTF-8 character")
		end

		return 4

	else
		error("Invalid UTF-8 character")
	end
end


local function utf8replace (s, mapping)
	-- argument checking
	if type(s) ~= "string" then
		error("bad argument #1 to 'utf8replace' (string expected, got ".. type(s).. ")")
	end
	if type(mapping) ~= "table" then
		error("bad argument #2 to 'utf8replace' (table expected, got ".. type(mapping).. ")")
	end
	local pos = 1
	local bytes = string.len(s)
	local charbytes
	local newstr = ""
	while pos <= bytes do
		charbytes = utf8charbytes(s, pos)
		local c = sub(s, pos, pos + charbytes - 1)
		newstr = newstr .. (mapping[c] or c)
		pos = pos + charbytes
	end
	return newstr
end
-- identical to string.upper except it knows about unicode simple case conversions
function new_utf8.upper (s)
	return utf8replace(s, utf8_lc_uc)
end
-- identical to string.lower except it knows about unicode simple case conversions
function new_utf8.lower (s)
	return utf8replace(s, utf8_uc_lc)
end

-- utf8.upper = string.upper
-- utf8.lower = string.lower

return new_utf8