--[[
    # String
    split
    ord
    chr
    sub
    tostr
]]

--- split( str, [separator,] [convert_numbers] )
-- Split a string into a table of elements delimited by the given separator (defaults to ",").  
--     str  
--         The string.  
--     separator  
--         The separator (defaults to ",").  
--     convert_numbers  
--         When convert_numbers is true, numerical tokens are stored as numbers (defaults to true).  
--  
-- The split() function splits a string into a table of elements delimited by the given separator (defaults to ",").  
-- Empty elements are stored as empty strings.  
-- When the separator is "", every character is split into a separate element.  
-- The separator can also be a number (say, N), in which case - the function splits the string after every N characters.   
function split(inputstr, sep, convert_numbers)
    if convert_numbers == nil then
        convert_numbers = true
    end
    if sep == nil then
        sep = ","
    end
    
    local t = {}
    
    if type(sep) == "number" then
        -- Split by fixed width
        for i = 1, #inputstr, sep do
            local token = inputstr:sub(i, i + sep - 1)
            if convert_numbers and tonumber(token) then
                table.insert(t, tonumber(token))
            else
                table.insert(t, token)
            end
        end
    elseif sep == "" then
        -- Split every character
        for i = 1, #inputstr do
            local token = inputstr:sub(i, i)
            if convert_numbers and tonumber(token) then
                table.insert(t, tonumber(token))
            else
                table.insert(t, token)
            end
        end
    else
        -- Split by separator
        local i = 1
        local a, b = nil, nil
        local stop = false
        repeat
            a, b = string.find(inputstr, sep, i)
            if not a then
                a = 0
                b = 0
                stop = true
            end
            
            local token = string.sub(inputstr, i, a-1)
            if convert_numbers and tonumber(token) then
                table.insert(t, tonumber(token))
            else
                table.insert(t, token)
            end
            i = b + 1
        until stop
    end
    
    return t
end


--- ord( str, [index,] [count] )  
-- Gets the ordinal (numeric) versions of an arbitrary number of characters in a string.  
-- str  
--     The string whose character(s) are to be converted to ordinal(s).  
-- index  
--     The index of the character in the string. Default is 1, the first character.  
-- count  
--     The number of characters to read from the string. Default is 1  
-- return-values  
--     The ordinal value(s) of the count character(s) at index in str, as a tuple.  
-- 
-- NOT IMPLEMENTED: P8SCII at 127 and over  
function ord(str, index, count)
    index = index or 1
    count = count or 1

    return string.byte(str, index, index+count-1)
end

-- chr( [ord [, ord2, [... ordn]]] )  
--     Gets the character(s) corresponding to ordinal (numeric) value(s).  
--     ord [, ord2, [... ordn]]  
--         Zero or more ordinal values (typically one) to be converted into characters in a string.  
--     return-value  
--         A string consisting of as many characters as there were ordinal values. Default output is an empty string.  
-- 
-- This function permits conversion of an arbitrary number of ordinal values to the
-- character(s) they correspond to, in the form of a string.   
function chr(...)
    return string.char(...)
end

-- sub( str, start, [end] )
--     Gets the substring of a string.
--     str
--         The string.
--     start
--         The starting index, counting from 1 at the left, or -1 at the right.
--     end
--         The ending index, counting from 1 at the left, or -1 at the right. (default -1)
function sub(str, a, b)
    return string.sub(str, a, b)
end

--- tostr( val, [format_flags] )  
-- Converts a non-string value to a string representation.  
-- val  
--     The value to convert.  
-- format_flags  
--     Bitfield which allows different operations to occur in the conversion  
-- NOT IMPLEMENTED: format_flags
function tostr(val, format_flags)
    return tostring(val)
end