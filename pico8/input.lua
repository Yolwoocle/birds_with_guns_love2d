local bit = require "bit"
local Files = (require "lib.options.files"):new()

--[[
    # Input
    btn
    btnp

    Input abstraction:
    - "button": refers to a PICO-8 button. For example, "O", "X", "Left", "Pause".
    - "key": refers to a physical key, keyboard, mouse, or controller. For example, keyboard "enter", controller left trigger.
        - "K": keyboard key (based off LÖVE Scancodes), start with "K". For example, "Kenter", "Kdown".
        - "M": mouse key, from mouse1 to mouse12. For example, "Mmouse1" for left click.
        - "C": controller key, start with "C". For example, "Ca", "Cleftshoulder".
            - May include the controller brand afterwards, for example "Cleftshoulder_PS4".
        - "?": only used for the "?unknown" key, which is when the engine cannot recognize the type.
        - All key types include the "unknown" key, which is when the engine recognizes the type but not the key.
            - Displayed "¿¿" to avoid ambiguity with the "?" key.
]]

function _init_input()
    __input_state = {}
    for btn_id, _ in pairs(DEFAULT_BTN_MAP) do
        __input_state[btn_id] = 0
    end

    __btn_map = Files:read_config_file("btn_map.txt", DEFAULT_BTN_MAP)
    __btn_map["$version"] = nil
    print_table(__btn_map)
    
    __reset_input_state()
    
    __standby_input_frames = 10

    __is_in_input_standby = false 
    __decativate_standby_on_next_frame = false
    __standby_button_code = nil
end

function __reset_input_state()
    for ip = 0, MAX_PLAYERS - 1 do
        for ib = 0, BTN_COUNT - 1 do
            __input_state[ip * BTN_COUNT + ib] = 0
        end
    end
end

-- Not implemented: Undocumented buttons (see https://pico-8.fandom.com/wiki/Btn)
function btn(btn_id, player)
    -- TODO: bitfield if called with no args (https://pico-8.fandom.com/wiki/Btn) + the rest
    if not btn_id then
        return 
            bit.lshift(1, 0)  * tonum(btn(0, 0)) +
            bit.lshift(1, 1)  * tonum(btn(1, 0)) +
            bit.lshift(1, 2)  * tonum(btn(2, 0)) +
            bit.lshift(1, 3)  * tonum(btn(3, 0)) +
            bit.lshift(1, 4)  * tonum(btn(4, 0)) +
            bit.lshift(1, 5)  * tonum(btn(5, 0)) +

            bit.lshift(1, 8)  * tonum(btn(0, 1)) +
            bit.lshift(1, 9)  * tonum(btn(1, 1)) +
            bit.lshift(1, 10) * tonum(btn(2, 1)) +
            bit.lshift(1, 11) * tonum(btn(3, 1)) +
            bit.lshift(1, 12) * tonum(btn(4, 1)) +
            bit.lshift(1, 13) * tonum(btn(5, 1))
    end

    player = player or 0 
    if (btn_id ~= BTN_PAUSE) and (btn_id < 0 or btn_id >= BTN_COUNT or player < 0 or player >= MAX_PLAYERS) then
        return false
    end
    local state = __input_state[player*BTN_COUNT + btn_id]
    return state == INPUT_STATE_ON or state == INPUT_STATE_PRESSING
end

function btnp(btn_id, player)
    if not btn_id then
        return 
            bit.lshift(1, 0)  * tonum(btnp(0, 0)) +
            bit.lshift(1, 1)  * tonum(btnp(1, 0)) +
            bit.lshift(1, 2)  * tonum(btnp(2, 0)) +
            bit.lshift(1, 3)  * tonum(btnp(3, 0)) +
            bit.lshift(1, 4)  * tonum(btnp(4, 0)) +
            bit.lshift(1, 5)  * tonum(btnp(5, 0)) +

            bit.lshift(1, 8)  * tonum(btnp(0, 1)) +
            bit.lshift(1, 9)  * tonum(btnp(1, 1)) +
            bit.lshift(1, 10) * tonum(btnp(2, 1)) +
            bit.lshift(1, 11) * tonum(btnp(3, 1)) +
            bit.lshift(1, 12) * tonum(btnp(4, 1)) +
            bit.lshift(1, 13) * tonum(btnp(5, 1))
    end

    player = player or 0 
    if (btn_id ~= BTN_PAUSE) and (btn_id < 0 or btn_id >= BTN_COUNT or player < 0 or player >= MAX_PLAYERS) then
        return false
    end
    local state = __input_state[player*BTN_COUNT + btn_id]
    return state == INPUT_STATE_PRESSING
end

function __update_input_state()
    __standby_input_frames = __standby_input_frames - 1
    
    for btn_id, _ in pairs(__btn_map) do
        local pressed = __is_btn_down(btn_id)
        local old_state = __input_state[btn_id]
        if old_state ~= nil then
            if pressed then
                if old_state == INPUT_STATE_OFF or old_state == INPUT_STATE_RELEASING then
                    __input_state[btn_id] = INPUT_STATE_PRESSING
                elseif old_state == INPUT_STATE_PRESSING then
                    __input_state[btn_id] = INPUT_STATE_ON
                end
            else
                if old_state == INPUT_STATE_RELEASING then
                    __input_state[btn_id] = INPUT_STATE_OFF
                elseif old_state == INPUT_STATE_ON or old_state == INPUT_STATE_PRESSING then
                    __input_state[btn_id] = INPUT_STATE_RELEASING
                end
            end
        end
    end
end

function __last_update_input()
    if __decativate_standby_on_next_frame then
        __decativate_standby_on_next_frame = false
        __is_in_input_standby = false
    end
end

function __is_btn_down(btn_id)
    if __is_in_input_standby or __standby_input_frames > 0 then
        return false
    end

    local keys = __btn_map[btn_id]
    if not keys then
        return false
    end

    for _, key in pairs(keys) do
        local key_type = sub(key, 1, 1)
        local key_code = sub(key, 2, -1)
        if key_type == "K" then
            if love.keyboard.isScancodeDown(key_code) then
                return true
            end
        end
    end
    return false
end

function __get_key_display_string(key)
    assert(#key > 0, "empty string given")
    local key_to_search = key
    local key_type = sub(key, 1, 1)
    local key_code = sub(key, 2, -1) 
    if key_type == "K" then
        --todo: use love.keyboard.getKeyFromScancode
    end

    local display_str = KEY_TO_DISPLAY_STRING[key] or KEY_TO_DISPLAY_STRING[key_type .. "unknown"]

    if not display_str then
        return KEY_TO_DISPLAY_STRING["?unknown"] or ""
    end


    return display_str
end

function __is_valid_key(key)
    return KEY_TO_DISPLAY_STRING[key]
end

--- When in standby mode, the engine will not update button states and wait until any valid key is pressed.
--- This is useful for input remapping screens.
function __start_input_standby(button_code)
    __standby_button_code = button_code

    __is_in_input_standby = true 
end

function __on_keypressed(key, scancode, isrepeat)
    if __is_in_input_standby then
        if __is_valid_key("K" .. scancode) then
            __on_standby_key_pressed("K" .. scancode)
        end
    end
end

function __on_standby_key_pressed(key)
    __decativate_standby_on_next_frame = true
    __standby_input_frames = 30

    local key_type = sub(key, 1, 1)
    local key_code = sub(key, 2, -1)

    assert(__btn_map[__standby_button_code], "Button code "..tostring(__standby_button_code).." has no corresponding input map")
    
    local found, index = contains(key, __btn_map[__standby_button_code])
    assert(index == nil or type(index) == "number", "Index isn't a number")
    if found then
        table.remove(__btn_map[__standby_button_code], index)
    else
        table.insert(__btn_map[__standby_button_code], key)
    end
end