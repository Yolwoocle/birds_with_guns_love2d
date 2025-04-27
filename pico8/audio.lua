--[[
    [ ] music
    [ ] sfx
]]

function _init_audio()
    if __music then
        music(-1)
    end
    if __sounds then
        for k, v in pairs(__sounds) do
            __sounds[k].source:stop()
        end
    end

    __sounds = {}
    for i=0, 63 do
        __sounds[i] = {
            source = love.audio.newSource("game/assets/sfx/sfx_"..tostring(i)..".wav", "static"),
            paused = false,
        }
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

    __sfxeffects = {}
    sfxeffect("lowpass", false)
end

-- NOT IMPLEMENTED: fadems, channelmask
function music(n, fadems, channelmask)
    n = n or 0
    if __current_music then
        sfxeffect("lowpass", false)
    end
    if n == -1 and __current_music then
        __current_music:stop()
    end
    
    local source = __music[n]
    if not source then
        return
    end
    __current_music = source
    __current_music:play()

    sfxeffect("lowpass", __sfxeffects["lowpass"])
end

-- NOT IMPLEMENTED: [channel,] [offset,] [length]
function sfx(n, channel, offset, length)
    if not __sounds[n] then
        return
    end
    local source = __sounds[n].source
    if source:isPlaying() then
        source:stop()
    end
	source:play()
end

function _pause_all_sources()
    for id, sound in pairs(__sounds) do
        if sound.source:isPlaying() then
            sound.source:pause()
            sound.paused = true
        end
    end

    if __current_music then
        __current_music:pause()
    end
end

function _resume_all_sources()
    for id, sound in pairs(__sounds) do
        if sound.paused then
            sound.source:play()
        end
        sound.paused = false
    end

    if __current_music then
        __current_music:play()
    end
end

function sfxeffect(effectname, value)
    __sfxeffects[effectname] = value

    if effectname == "lowpass" and __current_music then
        if value then
            __current_music:setFilter({
                type = "lowpass",
                highgain = value,
            })
        else
            __current_music:setFilter()
        end
    end
end