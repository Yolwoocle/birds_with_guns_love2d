local bit = require "bit"

local _menu_line_spacing = 2
local _menu_padding = 6
local _menu_width = 82

local Options = (require "lib.options.options"):new()

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

    local label_func
    local label_str
    if type(label) == "string" then
        label_func = function() return label end
        label_str = label
    elseif type(label) == "function" then
        label_func = label
        label_str = label()
    else
        assert(false, "Label param is neither string nor function")
    end

    local item = {
        original_label = label_str,
        label = label_str,
        label_func = label_func,
        callback = callback,
        init = params.init or function() return label end,
    }
    item.permanent = param(params.permanent, false)

    return item
end

function __reset_menus()
    local function toggle_labeller(label, option_name)
        return function() 
            return label.. ":" .. (Options:get(option_name) and "on" or "off")     
        end
    end
    local function toggle_setter(option_name)
        return function()
            Options:set(option_name, not Options:get(option_name))
        end
    end

    local function slider_labeller(label, option_name, steps)
        steps = steps or 8
        return function() 
            local v = round(Options:get(option_name) * steps)
            return label.. ": " .. (repeat_string("▮", v) .. repeat_string("-", steps - v))
        end
    end
    local function slider_setter(option_name, steps)
        steps = steps or 8
        return function(bitfield)
            local left = bit.band(1, bitfield) > 0
            local right = bit.band(2, bitfield) > 0
            if left then
                Options:set(option_name, mid(Options:get(option_name) - 1/steps, 0, 1))
            end
            if right then
                Options:set(option_name, mid(Options:get(option_name) + 1/steps, 0, 1))
            end
        end
    end

    local function lang_labeller(lang)
        return function() 
            return "{lang_"..lang.."} " .. (Options:get("language") == lang and "★" or " ")     
        end
    end
    local function lang_setter(lang)
        return function(bitfield)
            Options:set("language", lang)
        end
    end

    __menus = {
        pause = _new_menu(),
        options = _new_menu(),
        language = _new_menu(),
    }

    menuitem(1, "{menu_continue}", function()
        _unpause()
    end)
    menuitem(2, "{menu_restart}", function()
        run()
    end)
    menuitem(3, "{menu_options}", function()
        _set_menu("options")
    end)

    menuitem({"options", 1}, "{menu_back}", function()
        
    end)
    menuitem({"options", 2}, 
    toggle_labeller("{menu_sound_on}", "sound_on"), 
    toggle_setter("sound_on")
)
    menuitem({"options", 3}, 
    slider_labeller("{menu_volume}", "volume"), 
        slider_setter("volume")
    )
    menuitem({"options", 4}, 
    toggle_labeller("{menu_fullscreen}", "fullscreen"), 
        toggle_setter("fullscreen")
    )
    menuitem({"options", 4}, "{menu_language}", function()
        _set_menu("language")
    end)
    
    menuitem({"language", 1}, "{menu_back}", function()
        
    end)
    menuitem({"language", 2}, 
        lang_labeller("en"), 
        lang_setter("en")
    )
    menuitem({"language", 3}, 
        lang_labeller("fr"), 
        lang_setter("fr")
    )
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

    print(bitfield)
    click_func(bitfield)
end

function _update_menus(dt)
    if __current_menu then
        if btnp(BTN_UP) then
            __current_selection_index = mod1(__current_selection_index - 1, #__current_menu.items)

        elseif btnp(BTN_DOWN) then
            __current_selection_index = mod1(__current_selection_index + 1, #__current_menu.items)

        elseif btnp(BTN_O) or btnp(BTN_X) or btnp(BTN_LEFT) or btnp(BTN_RIGHT) then
            if __current_menu.items[__current_selection_index] then
                _click_item() 
            end
        end
    end

    for item in all(__current_menu.items) do
        item.label = item.label_func() or ""
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

    for i=1, #__current_menu.items do
        local val = __current_menu.items[i].init()
        __current_menu.items[i].label = val
    end

    -- Music effects
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
    assert(__menus[menu_name], "Menu '"..tostr(menu_name).."' doesn't exist")

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
