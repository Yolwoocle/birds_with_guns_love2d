--[[
    [ ] run
    [x] time
    [x] t (== time)
    [ ] menuitem
    [ ] printh
]]

local __time = 0
function _update_meta(dt)
    __time = __time + dt
end

function run(breadcrumb)
    __breadcrumb = breadcrumb
    __init()
end

function time()
    return __time
end
t = time

function printh(...)
    -- TODO
end

function quit(...)
    
    love.event.quit() 
end