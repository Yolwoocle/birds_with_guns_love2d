--[[
    [ ] run
    [x] time
    [x] t (== time)
    [ ] menuitem
    [ ] printh
]]

function run(breadcrumb)
    __breadcrumb = breadcrumb
    __init()
end

function time(...)
    return love.timer.getTime()
end
t = time

function menuitem(...)
    -- TODO
end

function printh(...)
    -- TODO
end