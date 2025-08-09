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

BTN_MAP = {
    [-1] = {"escape", "p", "return"},

    -- Player 1
    [0] = {"left"},
    [1] = {"right"},
    [2] = {"up"},
    [3] = {"down"},
    [4] = {"z", "c", "n"},
    [5] = {"x", "v", "m"},
    
    -- Player 2
    [6] = {"s"},
    [7] = {"f"},
    [8] = {"e"},
    [9] = {"d"},
    [10] = {"tab"},
    [11] = {"q"},
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
    "中文日本語한국어" -- characters used in the language selection screen 

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