require "pico8"

local test = {}

local function approxeq(x, y, epsilon)
    epsilon = epsilon or 0.001
    return math.abs(x - y) < epsilon
end

local function asserttest(c, msg)
    assert(c, "Test failed: "..tostring(msg))
end

local function assert_eq(a, b)
    asserttest(a == b, string.format("Expected %f, got %f", b, a))
end

local function assert_approxeq(a, b, epsilon)
    asserttest(approxeq(a, b, epsilon), string.format("Expected %f, got %f", b, a))
end

local function table_to_str(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. table_to_str(v) .. ', '
        end
        return s .. '} '
    elseif type(o) == "string" then
        return "\""..tostring(o).."\""
    else
        return tostring(o)
    end
end
 

local function assert_table_eq(actual, expected)
    asserttest(#actual == #expected, string.format("Expected table of length %d but got %d (expected: %s; got: %s)", #expected, #actual, table_to_str(expected), table_to_str(actual)))
    for i = 1, #actual do
        asserttest(actual[i] == expected[i], string.format("Expected %s at index %d but got %s (expected: %s; got: %s)", expected[i], i, actual[i], table_to_str(expected), table_to_str(actual)))
    end
end

function test.string()
    -- Split
    assert_table_eq(split("a,b,c", ",", false), {"a", "b", "c"})
    assert_table_eq(split("aaa,bb,ccccc", ",", false), {"aaa", "bb", "ccccc"})
    assert_table_eq(split("1,2,3"), {1, 2, 3})
    assert_table_eq(split("1,2,3", ",", false), {"1", "2", "3"})
    assert_table_eq(split("a,b,c", ",", false), {"a", "b", "c"})
    assert_table_eq(split("a,b,c", ";", false), {"a,b,c"})
    assert_table_eq(split("10 20 30", " ", true), {10, 20, 30})
    assert_table_eq(split("apple;banana;cherry", ";", false), {"apple", "banana", "cherry"})
    assert_table_eq(split("1,,3", ",", true), {1, "", 3})
    assert_table_eq(split("1,,3", ",", false), {"1", "", "3"})
    assert_table_eq(split("abcdef", "", false), {"a", "b", "c", "d", "e", "f"})
    assert_table_eq(split("abcdef", " ", false), {"abcdef"})
    assert_table_eq(split("123456", 2, true), {12, 34, 56})
    assert_table_eq(split("123456", 2, false), {"12", "34", "56"})
    assert_table_eq(split("123a56", 2, true), {12, "3a", 56})
    assert_table_eq(split("123a56", 1, true), {1, 2, 3, "a", 5, 6})

    assert_table_eq(split("1,2,3"), {1,2,3})
    assert_table_eq(split("one:two:3",":",false), {"one","two","3"})
    assert_table_eq(split("1,,2,"), {1,"",2,""})
    assert_table_eq(split("12345",2), {12,34,5})
end


function test.math()
    -- Min
    assert_eq(min(8), 0)
    assert_eq(min(-8), -8)
    assert_eq(min(0), 0)
    assert_eq(min(8, 2), 2)
    assert_eq(min(-3.5, -3.4), -3.5)
    assert_eq(min(6, 6), 6)

    -- Max
    assert_eq(max(8), 8)
    assert_eq(max(-8), 0)
    assert_eq(max(0), 0)
    assert_eq(max(8, 2), 8)
    assert_eq(max(-3.5, -3.4), -3.4)
    assert_eq(max(6, 6), 6)

    -- Mid
    assert_eq(mid(8, 2, 4), 4)
    assert_eq(mid(-3.5, -3.4, -3.6),  -3.5)
    assert_eq(mid(6, 6, 8), 6)
    assert_eq(mid(0, -1, 1), 0)
    assert_eq(mid(100, 50, 75), 75)
    assert_eq(mid(-10, -20, -15), -15)
    assert_eq(mid(5.5, 2.2, 4.4), 4.4)
    assert_eq(mid(3, 3, 5), 3)
    assert_eq(mid(-1, 0, 1), 0)

    -- Atan2
    assert_approxeq(atan2(1, 1), 0.875)
    assert_approxeq(atan2(-1, -1), 0.375)
    assert_approxeq(atan2(0, 1), 0.75)
    assert_approxeq(atan2(0.24, -32), 0.248)
    assert_approxeq(atan2(0, 0), 0.25)
    assert_approxeq(atan2(1, 0),   0)
    assert_approxeq(atan2(-1, 1),  0.625)
    assert_approxeq(atan2(-1, 0),  0.5)
    assert_approxeq(atan2(-1, -1), 0.375)
    assert_approxeq(atan2(0, -1),  0.25)
    assert_approxeq(atan2(1, -1),  0.125)

    -- Cos
    assert_approxeq(cos(0), 1)
    -- assert_approxeq(cos(0.125), 0.7071)
    assert_approxeq(cos(0.25), 0)
    assert_approxeq(cos(0.375), -0.7071)
    assert_approxeq(cos(0.5), -1)
    assert_approxeq(cos(0.625), -0.7071)
    assert_approxeq(cos(0.75), 0)
    assert_approxeq(cos(0.875), 0.7071)
    assert_approxeq(cos(1), 1)

    -- Sin
    assert_approxeq(sin(0)    , 0)
    assert_approxeq(sin(0.125), -0.7071)
    assert_approxeq(sin(0.25) , -1)
    assert_approxeq(sin(0.375), -0.7071)
    assert_approxeq(sin(0.5)  , 0)
    assert_approxeq(sin(0.625), 0.7071)
    assert_approxeq(sin(0.75) , 1)
    assert_approxeq(sin(0.875), 0.7071)
    assert_approxeq(sin(1)    , 0)
end

function test.table()
    local table = {1, 2, 3, 4, 5}
    local s = 0
    for x in all(table) do
        s = s + x
    end
    assert_eq(s, 15)
end

function test.test()
    test.string()
    test.table()
    test.table()
    print("Tests OK.")
end

return test