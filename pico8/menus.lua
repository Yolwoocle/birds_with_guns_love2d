function _init_menus()
    __paused = false
    
    __menus = {
        pause = {
            items = {
                {"continue", function()
                    _unpause()
                end},
                {"options", function()
                    _set_menu("options")
                end},
                {"restart", function()
                    run()
                end}
            }
        },
        options = {
            items = {
                {"options"}
            }
        }
    }

    __current_menu_name = nil
    __current_menu = nil
end

function _update_menus(dt)
    
end

local function _get_menu_height()
    if not __current_menu then
        return 0
    end

    local h = 0
    for i=1, #__current_menu.items do
        h = h + __font:getHeight()
    end
    return h
end

function _draw_menus()
    if not __paused or not __current_menu then
        return
    end
   
    local h = _get_menu_height() 
    local y0 = __height / 2 - h/2

    rectfill(32, y0, 64+32, y0+h, 1)
    
    local y = y0
    for i=1, #__current_menu.items do
        local str = __current_menu.items[i][1]
        print_(str, 32, y, 7)
        y = y + __font:getHeight()
    end
end

function _toggle_pause()
    if __paused then
        _unpause()
    else
        _pause()
    end
end

function _pause()
    _set_menu("pause")
end

function _unpause()
    _set_menu()
end

function _set_menu(name)
    if not name then
        __paused = false
        __current_menu_name = nil
        __current_menu = nil
        _resume_all_sources()
        return
    end
    if not __menus[name] then
        return
    end

    __paused = true
    __current_menu_name = name
    __current_menu = __menus[name]
    _pause_all_sources()
end