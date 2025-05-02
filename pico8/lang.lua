local languages = {
    en = require "game.lang.en"
}

function _init_lang()
    __fallback_lang_name = "en"
    __current_lang_name = "en"
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
    text = text:gsub("{lbrace}", "\1"):gsub("{rbrace}", "\2")
    
    text = text:gsub("{(.-)}", function(key)
        return tr_text(key)
    end)

    text = text:gsub("\1", "{"):gsub("\2", "}")
    return text
end