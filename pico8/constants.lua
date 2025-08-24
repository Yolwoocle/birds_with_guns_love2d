local utf8 = require "lib.utf8_fixes.utf8_fixes"
local function remove_repeats(str, start_offset)
    start_offset = start_offset or 0
    seen = {}
    output = utf8.sub(str, 1, start_offset)
    for i=start_offset+1, utf8.len(str) do
        local c = utf8.sub(str, i, i)
        if not seen[c] then
            seen[c] = true
            output = output..c
        end
    end
    return output
end

BTN_LEFT = 0
BTN_RIGHT = 1
BTN_UP = 2
BTN_DOWN = 3
BTN_O = 4
BTN_X = 5

BTN_COUNT = 6

BTN_PAUSE = -1

DEFAULT_BTN_MAP = {
    [-1] = {"Kescape", "Kp", "Kreturn"},

    -- Player 1
    [0] = {"Kleft"},
    [1] = {"Kright"},
    [2] = {"Kup"},
    [3] = {"Kdown"},
    [4] = {"Kz", "Kc", "Kn", "Mmouse2"},
    [5] = {"Kx", "Kv", "Km", "Mmouse1"},
    
    -- Player 2
    [6] = {"Ks"},
    [7] = {"Kf"},
    [8] = {"Ke"},
    [9] = {"Kd"},
    [10] = {"Ktab"},
    [11] = {"Kq"},
}

INPUT_STATE_OFF = 0
INPUT_STATE_PRESSING = 1 
INPUT_STATE_ON = 2
INPUT_STATE_RELEASING = 3

MAX_PLAYERS = 8

--                ▮■□⁙⁘‖◀▶「」¥•、。゛゜ !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~○█▒🐱⬇░✽●♥☉웃⌂⬅😐♪🅾◆…➡★⧗⬆ˇ∧❎▤▥あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをんっゃゅょアイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンッャュョ¡¿◜◝àáâãäåąæçćèéêëęìíîïłðñńòóôõöøùúûüśýźżœþßÀÁÂÃÄÅĄÆÇĆÈÉÊËĘÌÍÎÏŁÐÑŃÒÓÔÕÖØÙÚÛÜŚÝŹŻŒÞÿŸЁ
P8SCII_SYMBOLS = 
    "                ▮■□⁙⁘‖◀▶「」¥•、。゛゜ !\"#$%&'()*+,-./0123456789:;<=>?".. 
    "@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~".. 
    "○█▒🐱⬇░✽●♥☉웃⌂⬅😐♪🅾◆…➡★⧗⬆ˇ∧❎▤▥".. 
    "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれ".. 
    "ろわをんっゃゅょアイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメ"..
    "モヤユヨラリルレロワヲンッャュョ◜◝"

LATIN_EXTENDED_SYMBOLS = 
    "¡¿"..
    "àáâãäåąæçćèéêëęìíîïłðñńòóôõöøùúûüśýźżœþß".. 
    "ÀÁÂÃÄÅĄÆÇĆÈÉÊËĘÌÍÎÏŁÐÑŃÒÓÔÕÖØÙÚÛÜŚÝŹŻŒÞÿŸЁ"

ADDITIONAL_SYMBOLS = 
	"↵×○△□↩↪⏪⏩⏫⏬🕐🕑🕜🕝"

SIMPLIFIED_CHINESE_SYMBOLS = 
    "中文返回模式键盘鼠标手柄开关继续重新始选项语言控制退出音效量全屏题画面随机试再玩一次"..
    "更换鸟类移动左右上下射击切武器游戏作编程美术乐鸽子鸭麻雀鹦鹉巨嘴火烈老鹰海鸥鸵企鹅松"..
    "鸦鸡轮枪烟花发拳套箭筒焰喷光环炮霰弹突步狙加特林药生命值车厢时间杀没了结束恭喜在按住"..
    "解锁困难你是认真的吗这个本来就不该能通"

JAPANESE_SYMBOLS = 
    "英語フランス中国日本戻るモードキボマウゲムパッオ続け再開設定言操作終了音声量全画面タ"..
    "イトルダリもう一度鳥を変え移動左右上下攻撃武器更制コア楽ハヒズメシミゴワカチョペギケ".. 
    "ニバ花火ャクグ炎放射砲ガサナ弾薬体力車両時間破切れおめでと長押し解除嘘ょこの無理なは".. 
    "ずだった"

KOREAN_SYMBOLS = 
    "한국어뒤로모드키보마우스게임패켜짐꺼계속다시작옵션언조나가기소리음량전체화면타이틀랜".. 
    "덤재도하새바꾸동왼쪽오른위아래발사무변경제코그픽악비둘참앵투칸플라밍고독수갈매펭귄치".. 
    "닭볼버폭죽복싱글러브주카염방링캐논산탄총관돌격저미니건약력차간처없축해요튼을에서누르".. 
    "있으금진짜야는원불능데"

FONT_NORMAL_CHARSET = 
    P8SCII_SYMBOLS..
    LATIN_EXTENDED_SYMBOLS..
    "中文日本語한국어".. -- characters used in the language selection screen 
	ADDITIONAL_SYMBOLS

P8SCII_EXTENDED_SYMBOLS = remove_repeats(
    P8SCII_SYMBOLS..
    LATIN_EXTENDED_SYMBOLS..
    SIMPLIFIED_CHINESE_SYMBOLS..
    JAPANESE_SYMBOLS..
    KOREAN_SYMBOLS
, 16)

BASE_TEXT_HEIGHT = 6

LAYER_GAME = 1
LAYER_MENU = 2

-- ¡¿àáâãäåąæçćèéêëęìíîïłðñńòóôõöøùúûüśýźżœþß
-- ¡¿aaaaaaa.cceeeeeiiiil.nnoooooouuuusyzz...

-- Converts a key name to a string that can be displayed to the player
-- Some of these are not valid keys (e.g. "K@", because it doesn't correspond to a valid Scancode), 
-- but they may be used when displaying keys if the user is using a non-U.S. keyboard layout. (e.g., 
-- the key with the Scancode "/" on a AZERTY keyboard will be displayed as "[!]")
KEY_TO_DISPLAY_STRING = {
	["?unknown"] = "<¿¿>",

	["Kunknown"] = "[¿¿]",
	["Ka"] = "[a]",
	["Kb"] = "[b]",
	["Kc"] = "[c]",
	["Kd"] = "[d]",
	["Ke"] = "[e]",
	["Kf"] = "[f]",
	["Kg"] = "[g]",
	["Kh"] = "[h]",
	["Ki"] = "[i]",
	["Kj"] = "[j]",
	["Kk"] = "[k]",
	["Kl"] = "[l]",
	["Km"] = "[m]",
	["Kn"] = "[n]",
	["Ko"] = "[o]",
	["Kp"] = "[p]",
	["Kq"] = "[q]",
	["Kr"] = "[r]",
	["Ks"] = "[s]",
	["Kt"] = "[t]",
	["Ku"] = "[u]",
	["Kv"] = "[v]",
	["Kw"] = "[w]",
	["Kx"] = "[x]",
	["Ky"] = "[y]",
	["Kz"] = "[z]",
	["K0"] = "[0]",
	["K1"] = "[1]",
	["K2"] = "[2]",
	["K3"] = "[3]",
	["K4"] = "[4]",
	["K5"] = "[5]",
	["K6"] = "[6]",
	["K7"] = "[7]",
	["K8"] = "[8]",
	["K9"] = "[9]",
	["Kspace"] = "[space]",
	["K!"] = "[!]",
	["K\""] = "[\"]",
	["K#"] = "[#]",
	["K$"] = "[$]",
	["K&"] = "[&]",
	["K'"] = "[']",
	["K("] = "[(]",
	["K)"] = "[)]",
	["K*"] = "[*]",
	["K+"] = "[+]",
	["K,"] = "[,]",
	["K-"] = "[-]",
	["K."] = "[.]",
	["K/"] = "[/]",
	["K:"] = "[:]",
	["K;"] = "[;]",
	["K<"] = "[<]",
	["K>"] = "[>]",
	["K="] = "[=]",
	["K?"] = "[?]",
	["K@"] = "[@]",
	["K["] = "[[]",
	["K]"] = "[]]",
	["K\\"] = "[\\]",
	["K^"] = "[^]",
	["K_"] = "[_]",
	["K`"] = "[`]",
	["Kleft"] = "[⬅]",
	["Kright"] = "[➡]",
	["Kup"] = "[⬆]",
	["Kdown"] = "[⬇]",
	["Kinsert"] = "[ins]",
	["Kbackspace"] = "[bksp]",
	["Ktab"] = "[tab]",
	["Kreturn"] = "[↵]",
	["Kdelete"] = "[del]",
	["Kf1"] = "[f1]",
	["Kf2"] = "[f2]",
	["Kf3"] = "[f3]",
	["Kf4"] = "[f4]",
	["Kf5"] = "[f5]",
	["Kf6"] = "[f6]",
	["Kf7"] = "[f7]",
	["Kf8"] = "[f8]",
	["Kf9"] = "[f9]",
	["Kf10"] = "[f10]",
	["Kf11"] = "[f11]",
	["Kf12"] = "[f12]",
	["Kcapslock"] = "[capslock]",
	["Krshift"] = "[rshift]",
	["Klshift"] = "[lshift]",
	["Klctrl"] = "[lctrl]",
	["Krctrl"] = "[rctrl]",
	["Klalt"] = "[lalt]",
	["Kralt"] = "[ralt]",
	["Kkp0"] = "[kp0]",
	["Kkp1"] = "[kp1]",
	["Kkp2"] = "[kp2]",
	["Kkp3"] = "[kp3]",
	["Kkp4"] = "[kp4]",
	["Kkp5"] = "[kp5]",
	["Kkp6"] = "[kp6]",
	["Kkp7"] = "[kp7]",
	["Kkp8"] = "[kp8]",
	["Kkp9"] = "[kp9]",
	["Kkp."] = "[kp.]",
	["Kkp,"] = "[kp,]",
	["Kkp/"] = "[kp/]",
	["Kkp*"] = "[kp*]",
	["Kkp-"] = "[kp-]",
	["Kkp+"] = "[kp+]",
	["Kkpenter"] = "[kp↵]",
	["Kkp="] = "[kp=]",
	["Kescape"] = "[esc]",

	["Mmouse1"] = "[mb1]",
	["Mmouse2"] = "[mb2]",
	["Mmouse3"] = "[mb3]",
	["Mmouse4"] = "[mb4]",
	["Mmouse5"] = "[mb5]",
	["Mmouse6"] = "[mb6]",
	["Mmouse7"] = "[mb7]",
	["Mmouse8"] = "[mb8]",
	["Mmouse9"] = "[mb9]",
	["Mmouse10"] = "[mb10]",
	["Mmouse11"] = "[mb11]",
	["Mmouse12"] = "[mb12]",
	["Mwheelup"] = "[wheel⬆]",
	["Mwheeldown"] = "[wheel⬇]",

	["Cunknown"] = "(¿¿)",
	["Ca_XB"] = "(a)",
	["Cb_XB"] = "(b)",
	["Cx_XB"] = "(x)",
	["Cy_XB"] = "(y)",
	["Cback_XB"] = "(↩)",
	["Cguide_XB"] = "(⌂)",
	["Cstart_XB"] = "(↪)",
	["Cleftstick_XB"] = "(🕜)",
	["Crightstick_XB"] = "(🕝)",
	["Cleftshoulder_XB"] = "(lb)",
	["Crightshoulder_XB"] = "(rb)",
	["Cdpleft_XB"] = "(⏪)",
	["Cdpright_XB"] = "(⏩)",
	["Cdpup_XB"] = "(⏫)",
	["Cdpdown_XB"] = "(⏬)",
	["Cpaddle1_XB"] = "(pdl1)",
	["Cpaddle2_XB"] = "(pdl2)",
	["Cpaddle3_XB"] = "(pdl3)",
	["Cpaddle4_XB"] = "(pdl4)",
	["Ctouchpad_XB"] = "(touchpad)",
	["Cleftxneg_XB"] = "(🕐⬅)",
	["Cleftxpos_XB"] = "(🕐➡)",
	["Cleftyneg_XB"] = "(🕐⬆)",
	["Cleftypos_XB"] = "(🕐⬇)",
	["Crightxpos_XB"] = "(🕑⬅)",
	["Crightxneg_XB"] = "(🕑➡)",
	["Crightypos_XB"] = "(🕑⬆)",
	["Crightyneg_XB"] = "(🕑⬇)",
	["Ctriggerleft_XB"] = "(lt)",
	["Ctriggerright_XB"] = "(rt)",

	["Ca_NS"] = "(b)",
	["Cb_NS"] = "(a)",
	["Cx_NS"] = "(y)",
	["Cy_NS"] = "(x)",
	["Cback_NS"] = "(-)",
	["Cguide_NS"] = "(⌂)",
	["Cstart_NS"] = "(+)",
	["Cleftstick_NS"] = "(🕜)",
	["Crightstick_NS"] = "(🕝)",
	["Cleftshoulder_NS"] = "(l)",
	["Crightshoulder_NS"] = "(r)",
	["Cdpleft_NS"] = "(⏪)",
	["Cdpright_NS"] = "(⏩)",
	["Cdpup_NS"] = "(⏫)",
	["Cdpdown_NS"] = "(⏬)",
	["Cpaddle1_NS"] = "(gl)", -- I don't think that LÖVE supports NS2 controllers yet, but I added this for future-proofing.
	["Cpaddle2_NS"] = "(gr)",
	["Cpaddle3_NS"] = "(pdl3)",
	["Cpaddle4_NS"] = "(pdl4)",
	["Ctouchpad_NS"] = "(touchpad)",
	["Cleftxneg_NS"] = "(🕐⬅)",
	["Cleftxpos_NS"] = "(🕐➡)",
	["Cleftyneg_NS"] = "(🕐⬆)",
	["Cleftypos_NS"] = "(🕐⬇)",
	["Crightxpos_NS"] = "(🕑⬅)",
	["Crightxneg_NS"] = "(🕑➡)",
	["Crightypos_NS"] = "(🕑⬆)",
	["Crightyneg_NS"] = "(🕑⬇)",
	["Ctriggerleft_NS"] = "(zl)",
	["Ctriggerright_NS"] = "(zr)",

	["Ca_PS4"] = "(×)",
	["Cb_PS4"] = "(○)",
	["Cx_PS4"] = "(△)",
	["Cy_PS4"] = "(□)",
	["Cback_PS4"] = "(shr)",
	["Cguide_PS4"] = "(⌂)",
	["Cstart_PS4"] = "(opt)",
	["Cleftstick_PS4"] = "(🕜)",
	["Crightstick_PS4"] = "(🕝)",
	["Cleftshoulder_PS4"] = "(l1)",
	["Crightshoulder_PS4"] = "(r1)",
	["Cdpleft_PS4"] = "(⏪)",
	["Cdpright_PS4"] = "(⏩)",
	["Cdpup_PS4"] = "(⏫)",
	["Cdpdown_PS4"] = "(⏬)",
	["Cpaddle1_PS4"] = "(pdl1)",
	["Cpaddle2_PS4"] = "(pdl2)",
	["Cpaddle3_PS4"] = "(pdl3)",
	["Cpaddle4_PS4"] = "(pdl4)",
	["Ctouchpad_PS4"] = "(touchpad)",
	["Cleftxneg_PS4"] = "(🕐⬅)",
	["Cleftxpos_PS4"] = "(🕐➡)",
	["Cleftyneg_PS4"] = "(🕐⬆)",
	["Cleftypos_PS4"] = "(🕐⬇)",
	["Crightxpos_PS4"] = "(🕑⬅)",
	["Crightxneg_PS4"] = "(🕑➡)",
	["Crightypos_PS4"] = "(🕑⬆)",
	["Crightyneg_PS4"] = "(🕑⬇)",
	["Ctriggerleft_PS4"] = "(l2)",
	["Ctriggerright_PS4"] = "(r2)",
}

GAMEPAD_BRANDS = {
	["XB"] = {name = "xbox", fallbacks = {"XB"}},
	["NS"] = {name = "nintendo switch", fallbacks = {"XB"}},
	["PS4"] = {name = "playstation 4", fallbacks = {"XB"}},
}