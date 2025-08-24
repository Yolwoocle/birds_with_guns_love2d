require "lib.options.util"
local Class = require "lib.options.class"

local Files = Class:inherit()

function Files:init()
    
end


function Files:parse_value(str_value, reference_value)
    local val
    local typ = type(reference_value)
    if typ == "string" then
        val = str_value   
    elseif typ == "number" then
        val = tonumber(str_value)
    elseif typ == "boolean" then
        val = strtobool(str_value)
    elseif typ == "table" then
        val = split_str(str_value, ",") 
        for index, subval in pairs(val) do
            val[index] = self:parse_value(subval, (reference_value[index] or reference_value[1]) or "")
        end
    end

    return val
end


function Files:read_config_file(path, reference, create_if_missing)
    create_if_missing = param(create_if_missing, true)

    if not love.filesystem.getInfo then
        print("Files:read_config_file - /!\\ WARNING: love.filesystem.getInfo doesn't exist. Either running on web or LÖVE version is incorrect. Loading "..tostring(path).." aborted, so custom options will not be loaded.")
        return copy_table_deep(reference)
    end

    -- Check if file exists
    local options_file_exists = love.filesystem.getInfo(path)
    if not options_file_exists then
        if create_if_missing then
            print("'"..tostring(path).."' does not exist, so creating it")
            self.is_first_time = true
            self:write_config_file(path, reference)
        end
        return copy_table_deep(reference)
    end

    -- Read file
    local file = love.filesystem.openFile(path, "r")

    local text, size = file:read()
    if not text then    print("Files:read_config_file - Error reading '"..tostring(path).."' file: "..size)    end
    local lines = split_str(text, "\n") -- Split lines

    -- Read version
    local key, val = self:read_line(lines[1], reference, path)
    if (key ~= "$version") or (val ~= reference["$version"]) then
        -- Assuming incorrect version, resetting file
        print(concat("Files:read_config_file - Incorrect file veresion (", tostring(val), ") for '", path, "', defaults will be loaded."))
        self:write_config_file(path, reference)
        return copy_table_deep(reference)
    end

    local output = copy_table_deep(reference)
    for i = 2, #lines do
        local line = lines[i]
        local key, val = self:read_line(line, reference, path)
        if key ~= nil then
            output[key] = val
        end
    end
    
	file:close()
    
    return output
end

function Files:read_line(line, reference, path)
    local tab = split_str(line, ":")
    local raw_key, raw_value = tab[1], tab[2]

    if reference[raw_key] ~= nil then
        local key = raw_key -- Keys can be numbers or strings, this is a quick hack to check that
        if reference[key] == nil then
            key = tonum(key)
        end
        assert(key ~= nil, "Invalid key:"..tostring(raw_key))
        local val = self:parse_value(raw_value, reference[key])
        return key, val
    else
        print(concat("Files:read_line - Key error: key '",raw_key,"' for '",path,"' does not exist"))
    end
end


function Files:write_config_file(path, values) 
    -- Does not support writing the ":" character as it is used as separator. Good enough for now, implement escaping if needed.
    local file = love.filesystem.openFile(path, "w")

    if not values["$version"] then
        print(concat("Files:write_config_file - no '$version' field defined, assuming version 1"))
        values["$version"] = 1
    end
    local success, errmsg = file:write(concat("$version", ":", values["$version"], "\n"))
	
	for key, value in pairs(values) do
        if key ~= "$version" then
            local string_val = value
            if type(value) == "number" then   string_val = tostring(value)   end
            if type(value) == "boolean" then  string_val = tostring(value)   end
            if type(value) == "table" then    string_val = concatsep(value, ",")   end
    
            local success, errmsg = file:write(concat(key, ":", string_val, "\n"))
        end
	end
	
	file:close()
end

return Files