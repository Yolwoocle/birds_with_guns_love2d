local bit = require "bit"

local _menu_line_spacing = 2
local _menu_padding = 6
local _menu_width = 82

function _init_menus()
    __paused = false

    __menus = {}
    __reset_menus()

    __current_menu_name = nil
    __current_menu = nil

    __current_selection_index = 1
end

function _new_menu(params)
    params = params or {}

    local menu = {}
    menu.items = {}

    return menu
end

function _new_menu_item(label, callback, params)
    params = params or {}

    local item = {
        label = label,
        callback = callback
    }
    item.permanent = param(params.permanent, false)

    return item
end

function __reset_menus()
    __menus = {
        pause = _new_menu(),
        options = _new_menu(),
    }

    menuitem(1, "continue", function()
        _unpause()
    end)
    menuitem(2, "restart", function()
        run()
    end)
    menuitem(3, "options", function()
        _set_menu("options")
    end)

    -- menuitem({"options", 1}, "lolol", function()
    -- end)
end


local function _click_item()
    if not __current_menu or not __current_menu.items then
        return
    end

    local click_func = __current_menu.items[__current_selection_index].callback
    if not click_func then
        return 
    end

    local bitfield =
        bit.lshift(1, BTN_LEFT) * tonum(btn(BTN_LEFT)) +
        bit.lshift(1, BTN_RIGHT) * tonum(btn(BTN_RIGHT))
    if btn(BTN_O) or btn(BTN_X) or btn(BTN_PAUSE) then
        bitfield = bitfield +
            bit.lshift(1, BTN_O) +
            bit.lshift(1, BTN_X) +
            bit.lshift(1, BTN_PAUSE)
    end

    click_func(bitfield)
end

function _update_menus(dt)
    if __current_menu then
        if btnp(BTN_UP) then
            __current_selection_index = mod1(__current_selection_index - 1, #__current_menu.items)

        elseif btnp(BTN_DOWN) then
            __current_selection_index = mod1(__current_selection_index + 1, #__current_menu.items)

        elseif btnp(BTN_O) or btnp(BTN_X) then
            if __current_menu.items[__current_selection_index] then
                _click_item() 
            end
        end
    end
end

local function _get_menu_height()
    if not __current_menu then
        return 0
    end

    local h = 0
    for i = 1, #__current_menu.items do
        h = h + FONT_HEIGHT
        if i > 1 then
            h = h + _menu_line_spacing
        end
    end
    return h + 2 * _menu_padding
end

function _draw_menus()
    if not __paused or not __current_menu then
        return
    end

    local x0 = (__width - _menu_width) / 2

    local h = _get_menu_height()
    local y0 = flr(__height / 2 - h / 2)

    darkrect(x0, y0, __width - x0 - 1, y0 + h - 1)
    rect(x0 + 1, y0 + 1, __width - x0 - 2, y0 + h - 2, 7)

    local y = y0 + _menu_padding + 1
    for i = 1, #__current_menu.items do
        local str = __current_menu.items[i].label
        local selected = (__current_selection_index == i)

        if selected then
            print_("▶", x0 + 4 + (selected and 1 or 0), y, 7)
        end
        print_(str, x0 + 11 + (selected and 1 or 0), y, 7)
        y = y + FONT_HEIGHT + _menu_line_spacing
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

        sfxeffect("lowpass", __old_lowpass_value)

        return
    end
    if not __menus[name] then
        return
    end

    __paused = true
    __current_menu_name = name
    __current_menu = __menus[name]

    __current_selection_index = 1

    __old_lowpass_value = __sfxeffects["lowpass"]
    sfxeffect("lowpass", 0.003)

    _pause_all_sources()

    if __current_music then
        __current_music:play()
    end
end

function menuitem(index, label, callback)
    local menu_name = "pause"
    local i = index
    if type(index) == "table" then
        menu_name = index[1]
        i = index[2]
    end

    if type(i) == "number" then
        table.insert(__menus[menu_name].items, i, _new_menu_item(
            label, callback or function() end
        ))

    elseif __current_menu and __current_menu.items[__current_selection_index] then
        if label then
            __current_menu.items[__current_selection_index].label = label
        end

        if callback then
            __current_menu.items[__current_selection_index].callback = callback
        end


    end
end
