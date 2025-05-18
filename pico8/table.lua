--[[
    # Table
    add
    del
    all
    unpack
]]

function add(list, value, pos)
    pos = pos or (#list + 1)
    table.insert(list, pos, value)
    return value
end

function del(list, value)
    for i = 1, #list do
        if list[i] == value then
            table.remove(list, i)
            return list[i]
        end
    end
end

function all(t)
    -- I have not checked if this accurate to the PICO-8 version, but it seems to be.
    local i = 0
    local n = #t
    return function ()
        i = i + 1
        if i <= n then return t[i] end
    end
end