--[[
    # Input
    btn
    btnp
]]

function btn(btn_id, player)
    -- TODO: bitfield if called with no args (https://pico-8.fandom.com/wiki/Btn) + the rest
    player = player or 0 
    if btn_id < 0 or btn_id >= BTN_COUNT or player < 0 or player >= MAX_PLAYERS then
        return false
    end
    local state = __input_state[player*BTN_COUNT + btn_id]
    return state == INPUT_STATE_ON or state == INPUT_STATE_PRESSING
end

function btnp(btn_id, player)
    -- TODO: bitfield if called with no args (https://pico-8.fandom.com/wiki/Btnp) + the rest
    player = player or 0 
    if btn_id < 0 or btn_id >= BTN_COUNT or player < 0 or player >= MAX_PLAYERS then
        return false
    end
    local state = __input_state[player*BTN_COUNT + btn_id]
    return state == INPUT_STATE_PRESSING
end