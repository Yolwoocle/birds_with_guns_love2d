local bit = require "bit"

--[[
    # Input
    btn
    btnp
]]


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
    if btn_id < 0 or btn_id >= BTN_COUNT or player < 0 or player >= MAX_PLAYERS then
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
    if btn_id < 0 or btn_id >= BTN_COUNT or player < 0 or player >= MAX_PLAYERS then
        return false
    end
    local state = __input_state[player*BTN_COUNT + btn_id]
    return state == INPUT_STATE_PRESSING
end