local bit = require "bit"

local _menu_line_spacing = 3
local _menu_padding = 6
local _menu_width = 82

local Options = require "lib.options.options"

function _init_menus()
    __paused = false

    __menus = {}
    __menu_stack = {}
    __reset_menus()

    __current_menu_name = nil
    __current_menu = nil
    __current_menu_width = _menu_width

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

function __menu_back()
    if #__menu_stack == 0 then
        return
    end
    local menu = table.remove(__menu_stack)
    _set_menu(menu, {is_back = true})
end

function __reset_menus()
    local function on_click_callback(callback)
        return function(bitfield)
            if bit.band(bit.lshift(1, BTN_O), bitfield) > 0 then
                callback(bitfield)
            end
        end
    end
    local function toggle_labeller(label, option_name)
        return function()
            return label .. ":" .. (Options:get(option_name) and "{menu_on}" or "{menu_off}")
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
            return label .. ": " .. (repeat_string("▮", v) .. repeat_string("-", steps - v))
        end
    end
    local function slider_setter(option_name, steps)
        steps = steps or 8
        return function(bitfield)
            local left = bit.band(1, bitfield) > 0
            local right = (bit.band(2, bitfield) > 0) or (bit.band(bit.lshift(1, BTN_O), bitfield) > 0)
            if left then
                Options:set(option_name, mid(Options:get(option_name) - 1 / steps, 0, 1))
            end
            if right then
                Options:set(option_name, mid(Options:get(option_name) + 1 / steps, 0, 1))
            end
        end
    end

    local function lang_labeller(lang)
        return function()
            return "{lang_" .. lang .. "} " .. (Options:get("language") == lang and "★" or " ")
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
        quit_confirm = _new_menu(),
        controls = _new_menu(),
        controls_k_p1 = _new_menu(),
        controls_k_p2 = _new_menu(),
        controls_c_p1 = _new_menu(),
        controls_c_p2 = _new_menu(),
    }

    -- Pause
    menuitem(1, "{menu_continue}", on_click_callback(function()
        _unpause()
    end))
    menuitem(2, "{menu_restart}", on_click_callback(function()
        run()
    end))
    menuitem(3, "{menu_options}", on_click_callback(function()
        _set_menu("options")
    end))
    menuitem(4, "{menu_quit}", on_click_callback(function()
        _set_menu("quit_confirm")
    end))

    -- Quit confirm
    menuitem({"quit_confirm", 1}, "{menu_back}", on_click_callback(function()
        __menu_back()
    end))
    menuitem({"quit_confirm", 2}, "{menu_quit}", on_click_callback(function()
        quit()
    end))

    -- Options
    menuitem({ "options", 1 }, "{menu_back}", on_click_callback(function()
        __menu_back()
    end))
    menuitem({ "options", 2 },
        toggle_labeller("{menu_sound_on}", "sound_on"),
        toggle_setter("sound_on")
    )
    menuitem({ "options", 3 },
        slider_labeller("{menu_volume}", "volume"),
        slider_setter("volume")
    )
    menuitem({ "options", 4 },
        toggle_labeller("{menu_fullscreen}", "fullscreen"),
        toggle_setter("fullscreen")
    )
    menuitem({ "options", 5 }, "{menu_language}", on_click_callback(function()
        _set_menu("language")
    end))
    menuitem({ "options", 6 }, "{menu_controls}", on_click_callback(function()
        _set_menu("controls")
    end))

    -- Language
    menuitem({ "language", 1 }, "{menu_back}", on_click_callback(function()
        __menu_back()
    end))
    menuitem({ "language", 2 },
        lang_labeller("en"),
        lang_setter("en")
    )
    menuitem({ "language", 3 },
        lang_labeller("fr"),
        lang_setter("fr")
    )
    menuitem({ "language", 4 },
        lang_labeller("zh"),
        lang_setter("zh")
    )

    -- Controls
    menuitem({"controls", 1}, "{menu_back}", on_click_callback(function()
        __menu_back()
    end))
    menuitem({"controls", 2}, "{menu_input_mode_keyboard} 1", on_click_callback(function()
        _set_menu("controls_k_p1")
    end))
    menuitem({"controls", 3}, "{menu_input_mode_keyboard} 2", on_click_callback(function()
        _set_menu("controls_k_p2")
    end))
    menuitem({"controls", 4}, "{menu_input_mode_gamepad} 1", on_click_callback(function()
        _set_menu("controls_c_p1")
    end))
    menuitem({"controls", 5}, "{menu_input_mode_gamepad} 2", on_click_callback(function()
        _set_menu("controls_c_p2")
    end))
    
    -- Controls keyboard P1
    menuitem({"controls_k_p1", 1}, "{menu_back}", on_click_callback(function()
        __menu_back()
    end))
    menuitem({"controls_k_p1", 2}, "{action_left}: [a]", on_click_callback(function()
    end))
    menuitem({"controls_k_p1", 3}, "{action_right}: [d]", on_click_callback(function()
    end))
    menuitem({"controls_k_p1", 4}, "{action_up}: [w]", on_click_callback(function()
    end))
    menuitem({"controls_k_p1", 5}, "{action_down}: [d]", on_click_callback(function()
    end))
    menuitem({"controls_k_p1", 6}, "{action_shoot}: [x][v][n][mb1]", on_click_callback(function()
    end))
    menuitem({"controls_k_p1", 7}, "{action_change_weapon}: [c][z][b][mb2]", on_click_callback(function()
    end))
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
        elseif btnp(BTN_O) or btnp(BTN_X) or btnp(BTN_LEFT) or btnp(BTN_RIGHT) then
            if __current_menu.items[__current_selection_index] then
                _click_item()
            end
        end
    end

    __current_menu_width = _menu_width
    if __current_menu then
        for item in all(__current_menu.items) do
            item.label = item.label_func() or ""
            local w = get_text_width(_parse_text(item.label), __font) + 18
            __current_menu_width = max(__current_menu_width, w)
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

    local x0 = (__width - __current_menu_width) / 2

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

function _set_menu(name, params)
    params = params or {}
    if not name then
        __menu_stack = {}
        __paused = false
        __current_menu_name = nil
        __current_menu = nil

        sfxeffect("lowpass", __old_lowpass_value)

        return
    end
    if not __menus[name] then
        return
    end

    if not params.is_back then
        table.insert(__menu_stack, __current_menu_name)
    end
    __paused = true
    __current_menu_name = name
    __current_menu = __menus[name]

    __current_selection_index = 1

    for i = 1, #__current_menu.items do
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
    assert(__menus[menu_name], "Menu '" .. tostr(menu_name) .. "' doesn't exist")

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
