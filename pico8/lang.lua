local utf8 = require "lib.utf8_fixes.utf8_fixes"

local languages = {
    en = require "game.lang.en",
    fr = require "game.lang.fr",
    zh = require "game.lang.zh",
    ja = require "game.lang.ja",
    ja_Hrkt = require "game.lang.ja_Hrkt",
    ko = require "game.lang.ko",
}

function _init_lang()
    __fallback_lang_name = "en"
    __current_lang_name = "fr"
    __current_lang = languages[__current_lang_name]
end

function get_fallback_lang()
    return __fallback_lang_name
end

function get_lang_metadata()
    return __current_lang["$metadata"] or {}
end

function set_lang(lang)
    assert(languages[lang], "Language '"..tostring(lang).."' doesn't exist")

    __current_lang_name = lang
    __current_lang = languages[__current_lang_name]
end

function tr_text(id)
    local txt = __current_lang[id]
    if txt then
        return txt--.."xxx" 
    end

    txt = languages[__fallback_lang_name][id]
    if txt then
        return txt
    end

    return nil
end

function _parse_text(text)
    text = text
        :gsub("{lbrace}", "\1")
        :gsub("{rbrace}", "\2")
    
    text = text:gsub("{(.-)}", function(key)
        if utf8.len(key) > 0 and utf8.sub(key, 1, 1) == ":" then
            return __get_key_display_string(utf8.sub(key, 2, -1))
        end
        return tr_text(key)
    end)

    text = text
        :gsub("\1", "{")
        :gsub("\2", "}")
    return text
end