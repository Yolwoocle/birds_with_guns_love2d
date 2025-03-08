--[[
    [ ] music
    [ ] sfx
]]

function _init_audio()
    __sounds = {}
    __playing_sources = {}
    for i=0, 63 do
        __sounds[i] = love.audio.newSource("game/assets/sfx/sfx_"..tostring(i)..".wav", "static")
        __playing_sources[i] = false
    end
    
    __music = {}
    for i=0, 63 do
        local path = "game/assets/music/music_"..tostring(i)..".wav"
        if love.filesystem.getInfo(path) then
            print("loading "..path)
            __music[i] = love.audio.newSource("game/assets/music/music_"..tostring(i)..".wav", "stream")
        end
    end

    __current_music = nil
end

-- NOT IMPLEMENTED: fadems, channelmask
function music(n, fadems, channelmask)
    n = n or 0
    if n == -1 and __current_music then
        __current_music:stop()
    end
    
    local source = __music[n]
    if not source then
        return
    end
    __current_music = source
    __current_music:play()
end

-- NOT IMPLEMENTED: [channel,] [offset,] [length]
function sfx(n, channel, offset, length)
    if not __sounds[n] then
        return
    end
    local sound = __sounds[n]
    if sound:isPlaying() then
        sound:stop()
    end
	sound:play()
end