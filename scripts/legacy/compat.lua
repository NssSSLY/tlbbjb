-- 天龙助手兼容接口（本引擎实现）
-- 同名兼容函数使用固定游戏片段；游戏内执行时 GetLuaValue 另由常驻引擎直接调用游戏 Lua。
-- 外部兼容模式仍只接受已适配调用。两种模式均不加载原脚本程序的 DLL。
-- 原接口依据：script/自定义/[自定义] 接口说明.lua 及 dfz64.dll 中 common/common_2/bag/fn兼容接口 模块的静态反汇编。
local S, game, host, log, clock = __snippets, __game, __host, __log, __clock
__snippets, __game, __host, __log, __clock = nil, nil, nil, nil, nil

local function text(v) if v == nil then return "" end return tostring(v) end
local function trim(v) return (text(v):gsub("^%s+", ""):gsub("%s+$", "")) end
local once = {}
local function note(key, message) if not once[key] then once[key] = true; log(message) end end
local last_debug = nil
-- Fixed snippets keep numeric slots and append their string result. Never read
-- a numeric placeholder as NPC text, system messages, inventory rows or UI text.
local function text_result(...)
    local values=table.pack(game(...))
    for i=values.n,1,-1 do if type(values[i])=="string" then return values[1],values[i] end end
    return values[1],""
end
fmt=string.format

function PushDebugMessage(v) log(text(v)) end
DebugMessage = PushDebugMessage
PushColorMsg = PushDebugMessage
LogMsg = PushDebugMessage
LUOYANG_ID = 0 -- 洛阳场景号，0.2 实测
function DebugStr(v) v = text(v); if v ~= last_debug then last_debug = v; log(v) end end
function __cn_screen_text(v) log(text(v)) end
function __cn_wait(ms) Sleep(math.floor(tonumber(ms) or 0)) end
function ScriptOnStart(name) log("开始：" .. text(name)) end
function ScriptOnStop(name) log("结束：" .. text(name)) end
-- 系统提示：只读屏幕提示列表（约 5 秒后淡出）。原程序的 DeleteDebugMsg(key) 从提示记录里删掉匹配 key 的条目；
-- 这里记下当前已显示、匹配 key 的条目，之后只看新出现的。#{KEY} 形式先用游戏字典换成显示文字。
local consumed, dict_cache = {}, {}
local function debug_lines()
    local n, lines = text_result(S.DebugMessages)
    local out, present = {}, {}
    if not n then note("debugmsg", "系统提示读取失败；按原规则的次数上限执行"); return out end
    for line in text(lines):gmatch("[^\n]+") do out[#out + 1] = line; present[line] = true end
    for line in pairs(consumed) do if not present[line] then consumed[line] = nil end end
    return out
end
local function plain(v) return (text(v):gsub("#c%x%x%x%x%x%x", ""):gsub("#%a", "")) end
local function shown(key)
    local k = key:match("^#{([%w_]+)}?$")
    if not k then return key end
    if dict_cache[k] == nil then
        local _, v = text_result(S.DictText, nil, nil, k)
        v = text(v)
        dict_cache[k] = (v ~= "" and v ~= key and v ~= k) and v or key
    end
    return dict_cache[k]
end
local function matches(line, key)
    if line:find(key, 1, true) then return true end
    local p = plain(key)
    return p ~= "" and plain(line):find(p, 1, true) ~= nil
end
function DeleteDebugMsg(key)
    key = text(key)
    local wanted = key ~= "" and shown(key) or nil
    for _, line in ipairs(debug_lines()) do
        if not wanted or matches(line, wanted) then consumed[line] = true end
    end
end
function IsInDebugMsg(key)
    key = text(key); if key == "" then return false end
    local wanted = shown(key)
    for _, line in ipairs(debug_lines()) do
        if not consumed[line] and matches(line, wanted) then return true end
    end
    return false
end
function GetDictionaryString(key)
    local _, v = text_result(S.DictText, nil, nil, text(key))
    return text(v)
end

-- 位置来自已实测的内存读取；切图加载期间返回 nil。
local function position()
    local ok, scene, x, y, map = host("position")
    if not ok then return nil end
    return scene, x, y, map
end
function GetSceneID() local s = position(); return s or -1 end
function GetActiveSceneName() local _, _, _, m = position(); return m or "" end
GetCurrentSceneName = GetActiveSceneName
function Player_GetPos() local s, x, y = position(); if not s then return -1, -1 end; return x, y end

local function near(scene, x, y, range)
    local s, px, py = position()
    if not s or (scene >= 0 and s ~= scene) then return false end
    local dx, dy = px - x, py - y
    return dx * dx + dy * dy <= range * range
end

-- 原 MoveTo 调用游戏 AutoRunToTargetEx 后等待到达。停滞 8 秒重新提交，最多 4 次。
function MoveTo(x, y, scene, range, deadline)
    x, y = tonumber(x), tonumber(y)
    if not x or not y then error("MoveTo 坐标无效") end
    scene = tonumber(scene); if not scene or scene < 0 then scene = GetSceneID() end
    if scene < 0 then error("当前场景不可读，未提交寻路") end
    range = tonumber(range) or 2
    if near(scene, x, y, range) then return true end
    if NavigationCatalog and NavigationCatalog.runtime_enabled==true and GetSceneID()~=scene then
        if not NavigationRuntime then LoadScript('navigation_runtime') end
        -- Same-map hop approaches do not recurse into cross-map planning.
        if NavigationRuntime.travel(scene,x,y,range,MoveTo) then return true end
    end
    local issued, start, progress, lx, ly = 0, GetTickCount(), 0, nil, nil
    local route_confirmed = false
    while true do
        assert(not deadline or GetTickCount()<deadline,'导航超过总时限')
        if issued == 0 or GetTickCount() - progress > 8000 then
            if issued >= 4 then error(string.format("寻路未到达：场景 %s (%s,%s)", scene, x, y)) end
            game(S.RunTo, { scene }, { x, y })
            issued, progress = issued + 1, GetTickCount()
        end
        Sleep(500)
        local s, px, py = position()
        if s and near(scene, x, y, range) then return true end
        -- Only accept the game's specific cross-scene auto-route prompt; other dialogs stay untouched.
        if s and s ~= scene and not route_confirmed then
            local routePrompt = S.msgbox["你确认要开启跨场景自动寻路吗"]
            if routePrompt and game(S.MsgBoxText, { routePrompt }) == 1 then
                route_confirmed = true
                progress = GetTickCount()
                log("已确认跨场景自动寻路提示")
            end
        end
        if not s then progress = GetTickCount()
        elseif lx and math.abs(px - lx) + math.abs(py - ly) > 0.5 then progress = GetTickCount() end
        if s then lx, ly = px, py end
        if GetTickCount() - start > 600000 then error("寻路超过 10 分钟") end
    end
end

local function quest_open(ms)
    local start = GetTickCount()
    repeat
        if game(S.QuestOptions) == 1 then return true end
        Sleep(200)
    until GetTickCount() - start > ms
    return false
end
function TalkNpc(name, sleep)
    game(S.NpcTarget, nil, nil, trim(name))
    if sleep then Sleep(sleep) end
end
local function talk_at(name, x, y, scene, deadline)
    name = trim(name)
    MoveTo(x, y, scene, 3, deadline)
    Sleep(500)
    scene = tonumber(scene); if not scene or scene < 0 then scene = GetSceneID() end
    -- Original GoToSceneNPC finishes movement, then calls TalkNpc only. Starting
    -- another run command here can reset the arrival/interaction state.
    game(S.NpcTarget,nil,nil,name)
    Sleep(500)
    if not quest_open(10000) then error("未确认 NPC 对话，未提交领取 / 兑换：" .. name) end
end
function MoveToNPC(a, b, c, d)
    if type(a) == "number" then talk_at(d, a, b, c) else talk_at(a, b, c, d) end
end
function GoToSceneNPC(name, x, y, scene, deadline) talk_at(name, x, y, scene, deadline) end
function __cn_cross_map(map, x, y)
    local ids = { ["洛阳"] = 0, ["苏州"] = 1, ["大理"] = 2 }
    local scene = ids[trim(map)]
    if not scene then error("跨图寻路尚未核对地图：" .. text(map)) end
    return MoveTo(x, y, scene)
end

-- 闭环保护：任务在 NPC 对话操作（点选项 / 接交任务按钮，不论是否成功）之后反复读同一物品数量，
-- 连续 6 次都没有变化，说明兑换或上缴没有生效（选项不对、次数用完、对话没打开等）；
-- 停止任务并写明原因，由工作流按“失败处理”继续下一项，而不是一直重复同一操作。
local acted, last_count, stale = false, {}, {}
local function watch_count(key, n)
    if acted then
        if last_count[key] == n then
            stale[key] = (stale[key] or 0) + 1
            if stale[key] >= 6 then
                error(key .. " 的数量在连续 6 次 NPC 操作后没有变化，兑换 / 上缴没有生效，已停止，避免重复操作", 0)
            end
        else
            stale[key] = 0
        end
    end
    last_count[key] = n
    acted = false
    return n
end
-- 循环里同一状态连续出现 limit 次（没有进展）就停止任务并写明原因。
function NoProgress(task, limit)
    local last, same = nil, 0
    return function(state)
        state = text(state)
        if state == last then same = same + 1 else last, same = state, 0 end
        if same >= limit then
            error(text(task) .. "：连续 " .. same .. " 轮没有进展，已停止，避免重复操作（状态 " .. state .. "）", 0)
        end
    end
end

-- 0 模糊匹配，1 精确匹配；对话框未出现时返回 false，与原接口一致。
function QuestFrameOptionClicked(option, mode)
    acted = true
    if not quest_open(3000) then return false end
    return game(S.QuestOption, { mode == 1 and 1 or 0 }, nil, trim(option)) == 1
end
-- 原程序的 _Item 变体按选项文本点击；本程序与 DialogOptionClicked 使用同一游戏选项接口。
function QuestFrameOptionClicked_Item(option, cmp, sleep) return DialogOptionClicked(option, cmp, sleep) end
function DialogOptionClicked(option, cmp, sleep)
    if cmp == nil then cmp = 1 end
    local ok = QuestFrameOptionClicked(option, cmp)
    if ok and sleep then Sleep(sleep) end
    return ok
end
local function quest_button(kind, item, sleep)
    acted = true
    for _ = 1, 5 do
        if game(S.QuestButton, { kind, item or 0 }) ~= 1 then break end
        Sleep(200)
        if kind == 1 then break end
    end
    if sleep then Sleep(sleep) end
end
function QuestFrameAcceptClicked(sleep) quest_button(1, 0, sleep) end
function QuestFrameNextClicked(sleep) quest_button(2, 0, sleep) end
function QuestFrameMissionComplete(item, sleep) quest_button(3, tonumber(item) or 0, sleep) end
function MessageBox_Self_OK_Clicked() GetLuaValue("setmetatable(_G, {__index = MessageBox_Self_Env});MessageBox_Self_OK_Clicked()") end

function IsWindowVisible(window, action)
    window = trim(window)
    if action ~= nil then
        return GetLuaValue("setmetatable(_G, {__index = " .. window .. "_Env});" .. text(action))
    end
    return game(S.WindowVisible, nil, nil, window) == 1
end
function CloseAllWindow() game(S.CloseAll); Sleep(100) end

local function bag_count(name)
    name = trim(name)
    if name == "" then return 0 end
    return game(S.BagCount, nil, nil, name) or 0
end
Bag = { GetItemCount = function(_, name) return bag_count(name) end }
function FindBagItem(_, name)
    local n = bag_count(name)
    return n > 0, n, n > 0 and 0 or -1
end
-- 仓库/锦囊：依据 bag 模块 Bank_CheckBankPos/Bank_GetItem/Bank_GetMoney/Bank_SaveMoney/TempBank2Bag 的反汇编。
-- 仓库 NPC 坐标取自原程序；先走到 NPC，点“打开银行”，小仓库界面切换到大仓库后操作。
local bank_npcs = {
    ["洛阳"] = { { "卫先生", 347, 248, 0 }, { "褚先生", 191, 299, 0 } },
    ["苏州"] = { { "严伙计", 187, 279, 1 }, { "梁伙计", 343, 246, 1 } },
    ["大理"] = { { "何伙计", 217, 174, 2 } },
    ["楼兰"] = { { "庞伙计", 219, 122, 246 } },
    ["凤鸣镇"] = { { "钱先生", 265, 118, 850 } },
    ["金陵"] = { { "钱先生", 338, 351, 762 } },
}
local function bank_state()
    local small, big, money, carried = game(S.BankState)
    return small == 1, big == 1, money or 0, carried or 0
end
local function wait_bank(ms)
    local start = GetTickCount()
    repeat
        local small, big = bank_state()
        if big then return true end
        if small then game(S.BankBig); Sleep(500) else Sleep(300) end
    until GetTickCount() - start > ms
    return false
end
local function open_bank()
    local small, big = bank_state()
    if big then return true end
    if not small then
        local map = (GetActiveSceneName():gsub("%d线$", ""))
        local list = bank_npcs[map] or bank_npcs["洛阳"]
        local pick, best = list[1], nil
        if bank_npcs[map] and #list > 1 then
            local x, y = Player_GetPos()
            for _, npc in ipairs(list) do
                local d = (npc[2] - x) ^ 2 + (npc[3] - y) ^ 2
                if not best or d < best then pick, best = npc, d end
            end
        end
        GoToSceneNPC(pick[1], pick[2], pick[3], pick[4])
        Sleep(500)
        QuestFrameOptionClicked("打开银行", 0)
    end
    if wait_bank(10000) then return true end
    PushDebugMessage("打开仓库超时！可能密保验证没过")
    return false
end
local function names_of(v)
    local list = {}
    for w in text(v):gmatch("%S+") do list[#list + 1] = w end
    return list
end
local function wait_change(read, before, ms)
    local start = GetTickCount()
    repeat Sleep(300); local now = read(); if now ~= before then return now end until GetTickCount() - start > ms
    return before
end

-- 正数：包里至少有这么多铜；负数：仓库只保留这么多铜，其余取出。
function Bank_GetMoney(amount)
    amount = math.floor(tonumber(amount) or 0)
    if amount == 0 then DebugStr("取金币参数为0") return false end
    local _, _, _, carried = bank_state()
    if amount > 0 and carried >= amount then return true end
    if not open_bank() then return false end
    local _, _, stored
    _, _, stored, carried = bank_state()
    local need = amount > 0 and amount - carried or stored + amount
    if need > 0 and game(S.BankMoney, { 1, math.min(need, 2000000000) }) > 0 then
        wait_change(function() local _, _, _, c = bank_state() return c end, carried, 10000)
    end
    CloseAllWindow()
    return true
end
function Bank_SaveMoney(keep)
    keep = math.max(0, math.floor(tonumber(keep) or 0))
    local _, _, _, carried = bank_state()
    if carried - keep <= 0 then return true end
    if not open_bank() then return false end
    _, _, _, carried = bank_state()
    local saved = 0
    if carried - keep > 0 then saved = game(S.BankMoney, { 2, math.min(carried - keep, 2000000000) }) end
    if saved > 0 then
        wait_change(function() local _, _, _, c = bank_state() return c end, carried, 10000)
        PushColorMsg(string.format("银行存钱：本次存入 %.2f 金", saved / 10000))
    end
    CloseAllWindow()
    return true
end
-- 名称用空格分隔；count>0 时取够该数量即停。绑定/加锁筛选参数未接入，按名称取。
function Bank_GetItem(names, count)
    local list = names_of(names)
    if #list == 0 or not open_bank() then return false end
    count = tonumber(count) or -1
    local took = false
    for _, name in ipairs(list) do
        local start = bag_count(name)
        for _ = 1, 40 do
            local before = bag_count(name)
            if count > 0 and before - start >= count then break end
            local r, total = game(S.BankItem, { 1 }, nil, name)
            if r ~= 1 then
                if not took and (total or 0) == 0 then PushColorMsg("仓库取物：仓库没有需要取出的物品") end
                break
            end
            took = true
            PushDebugMessage("仓库取出：" .. name)
            if wait_change(function() return bag_count(name) end, before, 3000) == before then break end
        end
    end
    CloseAllWindow()
    return took
end
-- bind：0 不限，1 只存非绑定，2 只存绑定（与原程序 aBindState 一致）。
function Bank_SaveItem(names, _, bind)
    bind = tonumber(bind) or 0
    if bind < 0 or bind > 2 then bind = 0 end
    local list = names_of(names)
    if #list == 0 or not open_bank() then return false end
    local saved = false
    for _, name in ipairs(list) do
        for _ = 1, 40 do
            local before = bag_count(name)
            if before == 0 or game(S.BagStore, { bind }, nil, name) ~= 1 then break end
            saved = true
            if wait_change(function() return bag_count(name) end, before, 3000) == before then break end
        end
    end
    CloseAllWindow()
    return saved
end
local function temp_take(names)
    local list = table.concat(names_of(names), " ")
    local all = list == "ALL_ITEM"
    if list == "" then return false end
    if game(S.WindowVisible, nil, nil, "Packet_Temporary") ~= 1 then
        game(S.UiCall, { S.ui.Packet_Temporary_BtnClick, 0 })
        Sleep(500)
    end
    -- 名称列表按片段文本上限分批提交。
    local batches, current = {}, ""
    for _, name in ipairs(names_of(list)) do
        if current ~= "" and select(2, (current .. " " .. name):gsub("[^\128-\191]", "")) > 40 then batches[#batches + 1] = current; current = name
        else current = current == "" and name or current .. " " .. name end
    end
    batches[#batches + 1] = current
    local moved = 0
    for _, batch in ipairs(all and { "" } or batches) do
        local n = game(S.TempBag, { all and 1 or 0 }, nil, (not all) and batch or nil)
        if n == -1 then PushDebugMessage("锦囊界面未打开") return false end
        moved = moved + n
    end
    if moved > 0 then PushColorMsg(list .. ":从锦囊取出到背包"); Sleep(500) end
    game(S.CloseNamed, { S.windows.Packet_Temporary })
    return moved > 0
end
function TempBank2Bag(names) return temp_take(names) end
function BankTemp2Bag(names) return temp_take(names) end

-- 扫荡副本：依据 functions 模块 SDFB_OnStart 与 SD_* 局部函数的反汇编。
-- 原规则扫荡前后的清包、出售和存仓依赖配置与物品销毁，未接入；系统提示检测返回 false。
local sweep_names = { yzw = "讨伐燕子坞", sjz = "苏州四绝庄", sss = "少室山", bsqz = "兵圣奇阵", fmwl = "凤鸣王陵",
    sshj = "三神幻境", pmf = "挑战缥缈峰", lhfd_easy = "琅嬛福地（普通）", lhfd = "琅嬛福地（困难）", lsh = "除匪首力破三关" }
local sweep_order = { "yzw", "sjz", "sss", "bsqz", "fmwl", "sshj", "pmf", "lhfd_easy", "lhfd", "lsh" }
local function visible(window) return game(S.WindowVisible, nil, nil, window) == 1 end
local function ui(name, arg) return game(S.UiCall, { S.ui[name], arg or 0 }) end
local function sweep_selected(name, param)
    for _, key in ipairs(sweep_order) do if param[key] and name == sweep_names[key] then return true end end
    return false
end
local function sweep_enum(index)
    local low, high, kind, need, action, left, fuben, _, name = game(S.SweepEnum, { index })
    return name or "nil", low or 0, high or 0, kind or 0, need or 0, action or 0, left or 0, fuben or 0
end
local function sweep_action(name, param)
    local start = GetTickCount()
    while visible("SweepPage") do
        note("sweepbag", "扫荡前清理背包（吃绑定物品/清包）尚未接入，已跳过")
        local guard=rawget(_G,"__SweepGuard")
        local candidate=guard and guard.peekBoss() or nil
        if guard and candidate>0 then guard.beforeBoss(candidate) end
        local boss=(guard and candidate==0) and 0 or game(S.SweepBoss)
        if guard and candidate~=0 then guard.verifyBoss(candidate,boss) end
        if guard and candidate==0 then
            Sleep(500)
        else
        if boss == -2 then ui("SweepPage_OnBossButton", 4); Sleep(600) end
        Sleep(500)
        if visible("SanShen_BaoXiang") then
            if param.sshj_usekey and bag_count("天星灵符") > 0 then ui("SanShen_BaoXiang_OpenLingfu") else ui("SanShen_BaoXiang_OpenFree") end
            Sleep(200)
            ui("SweepPage_OnOkClicked")
            break
        end
        if boss < 0 then break end
        Sleep(500)
        ui("SweepPage_OnOkClicked")
        Sleep(1000)
        DebugStr(name .. ":扫荡中")
        end
        if GetTickCount() - start > 60000 then
            if guard then error(name .. ":扫荡页面超时，结果未确认") end
            PushDebugMessage(name .. ":扫荡超时") break
        end
    end
    game(S.CloseNamed, { S.windows.SweepPage })
    game(S.CloseNamed, { S.windows.Shop })
end
local function sweep_page(name, fuben, param)
    local guard=rawget(_G,"__SweepGuard")
    if guard then guard.beforePage(name,fuben) end
    game(S.CloseNamed, { S.windows.SweepPage })
    Sleep(100)
    game(S.SweepOpenPage, { fuben })
    for _ = 1, 5 do
        if visible("SweepPage") then
            sweep_action(name, param)
            if not visible("SweepAll") then ui("PlayerQuicklyEnter_OpenSecKillBox"); Sleep(600) end
            if guard then guard.afterPage(name,fuben) end
            return
        end
        if not guard then game(S.SweepOpenPage, { fuben }) end
        Sleep(800)
    end
    if guard then error(name .. ":扫荡页面未确认打开，停止且不重新提交") end
end
function SDFB_OnStart(param)
    param = type(param) == "table" and param or {}
    param.sshj_usekey = true
    local start = GetTickCount()
    if not visible("SweepAll") then ui("PlayerQuicklyEnter_OpenSecKillBox"); Sleep(1000) end
    while true do
        if visible("SweepAll") then
            local found = false
            local inSweep, fuben, index = game(S.SweepData)
            if inSweep == 1 then
                found = true
                PushDebugMessage("扫荡副本：有未扫荡完成" .. text(fuben))
                sweep_page((sweep_enum(index)), fuben, param)
            else
                for i = 0, (game(S.SweepCount) or 0) - 1 do
                    local name, low, high, kind, need, _, left, id = sweep_enum(i)
                    local busy, current = game(S.SweepData)
                    if busy == 1 and current ~= id then
                        found = true
                        PushDebugMessage("有未扫荡完的副本 " .. name .. " " .. text(id))
                        break
                    end
                    if sweep_selected(name, param) and left > 0 then
                        if (kind == 2 and need <= high) or (kind ~= 2 and need <= low) then
                            found = true
                            sweep_page(name, id, param)
                            break
                        end
                        PushDebugMessage(string.format("扫荡副本：%s 剩余点数%d,不够扫%d次", name, kind == 2 and high or low, left))
                    end
                end
            end
            if not found then LogMsg("扫荡副本：无可扫荡副本") break end
        else
            ui("PlayerQuicklyEnter_OpenSecKillBox")
        end
        if GetTickCount() - start > 1200000 then LogMsg("扫荡副本：超时") break end
        Sleep(1000)
        DebugStr("扫荡副本")
    end
    note("sweepafter", "扫荡后的出售与存仓依赖原程序配置，未执行")
end

local function data(key)
    local index = S.keys[key]
    if not index then error("角色数据项尚未接入：" .. text(key)) end
    return game(S.PlayerData, { index }) or -1
end
Player = {
    GetData = function(_, key) return data(key) end,
    GetDataInt = function(_, key) return data(key) end,
    -- Player:GetMoney(1) 金币，(2) 交子
    GetMoney = function(_, kind) return data(kind == 2 and "MONEY_JZ" or "MONEY") end,
}
function GetMoney(kind) return data(kind == 2 and "MONEY_JZ" or "MONEY") end
function GetPlayerInfo(key) if key == "LEVEL" then return data("LEVEL") end error("角色信息项尚未接入：" .. text(key)) end
function GetHPPercent() local hp, max = data("HP"), data("MAXHP"); if max <= 0 then return 0 end return hp * 100 // max end
function GetMPPercent() local mp, max = data("MP"), data("MAXMP"); if max <= 0 then return 0 end return mp * 100 // max end

function __cn_wait_team(count, message)
    count = math.floor(tonumber(count) or 0)
    if count < 1 or count > 6 then error("队伍人数应为 1–6") end
    if message and trim(message) ~= "" then log("喊话尚未接入，未发送：" .. trim(message)) end
    local last = -1
    while true do
        local n = GetTeamCount()
        if n ~= last then last = n; log(string.format("队伍人数 %d / %d", n, count)) end
        if n >= count then return end
        Sleep(1000)
    end
end

-- 指定时刻已过则等待到次日同一时刻，与工具页“等待到指定时间”一致。
function WaitForTime(hour, minute)
    hour, minute = math.floor(tonumber(hour) or -1), math.floor(tonumber(minute) or -1)
    if hour < 0 or hour > 23 or minute < 0 or minute > 59 then error("等待时刻无效") end
    local now, h, m, s = clock()
    local wait = (hour * 3600 + minute * 60) - (h * 3600 + m * 60 + s)
    if wait < 0 then wait = wait + 86400 end
    local target = now + wait
    log(string.format("等待到 %02d:%02d", hour, minute))
    while true do
        local current = clock()
        if current >= target then return end
        Sleep(math.min(60000, (target - current) * 1000))
    end
end
function __cn_wait_until(value)
    local h, m = string.match(trim(value), "^(%d+)[:：](%d+)$")
    if not h then error("时间格式应为 HH:MM") end
    WaitForTime(tonumber(h), tonumber(m))
end

function __cn_music_alarm() host("alert", "sound") end
function __cn_flash_window() host("alert", "flash") end
function __cn_run_script(name) error("暂不支持执行其他脚本：" .. text(name)) end
-- 扫荡副本模块已由本文件实现，其余原程序模块未接入。
function LoadScript(name)
    name = trim(name)
    if name == "fn扫荡副本" or name == "fnInterface" or name == "mission" then return end
    if name == "[功能] 物品存仓" then note("banksave", "物品存仓依赖原程序存仓配置，未执行") return end
    if name == "科举.lua" then
        if not KejuQ then error("科举题库未加载") end
        Q, A = KejuQ, KejuA
        return
    end
    error("暂不支持加载原程序模块：" .. text(name))
end
function __cn_unsupported() error("该接口尚未接入（队伍/坐骑/物品使用）") end

-- 商会取钱：依据 bag 模块 ShangHui_GetMoney（原自定义脚本里的 PS_GetMoney 是它的旧名）。
-- 洛阳乔复盛打开商会管理，从商会利润中取出差额；原规则的换线（ChangeSceneLine）未接入。
function ShangHui_GetMoney(amount)
    if type(amount) ~= "number" then PushDebugMessage("商会取钱：参数有误,应是整型！") return end
    amount = math.floor(amount)
    if amount > 0 and data("MONEY") >= amount then return true end
    note("changeline", "商会取钱：原规则会换到可用线路，本程序保持当前线路")
    GoToSceneNPC("乔复盛", 330, 299, 0)
    local start = GetTickCount()
    while true do
        if visible("PS_ShopMag") then
            local need = amount - data("MONEY")
            if need <= 0 or game(S.ShopMoney, { math.min(need, 2000000000) }) == 0 then return end
            Sleep(3000)
        else
            GoToSceneNPC("乔复盛", 330, 299, 0)
            Sleep(500)
            DialogOptionClicked("#{RCYH_180606_105}", 1, 700)
        end
        if amount <= data("MONEY") then return end
        if GetTickCount() - start > 15000 then PushDebugMessage("商会取钱:超时!可能密保验证没过或金币不够") return end
        Sleep(1000)
        DebugStr("商会取钱")
    end
end
PS_GetMoney = ShangHui_GetMoney

-- 合成宝石：依据 物品/合成宝石.lua 模块的反汇编；原自定义脚本用 g_GemHCnum（几合一）和 g_GemHCMS（0 不绑、1 绑定、2 混合）。
-- 1–3 级用低级合成符，4–6 级用高级，7–8 级用超级；在洛阳彭怀玉的宝石合成界面调用 LifeAbility:Do_Combine。
local function gem_list(source)
    local _, _, lines = game(S.GemList, { source })
    local list = {}
    for line in text(lines):gmatch("[^\n]+") do
        local name, bind, num, level = line:match("^(.-)\t(%-?%d+)\t(%d+)\t(%d+)$")
        if name then list[#list + 1] = { name = name, bind = tonumber(bind), num = tonumber(num), level = tonumber(level) } end
    end
    return list
end
local function gem_names(list)
    local seen, names = {}, {}
    for _, g in ipairs(list) do
        if g.level >= 1 and g.level <= 8 and not seen[g.name] then seen[g.name] = true; names[#names + 1] = g.name end
    end
    return names
end
function MainHCGem()
    local count = ({ [3] = 3, [4] = 4, [5] = 5 })[tonumber(g_GemHCnum)] or 5
    local mode = ({ [0] = 0, [1] = 1, [2] = 2 })[tonumber(g_GemHCMS)] or 0
    local title = "合成宝石"
    local start, fetched = GetTickCount(), { temp = false, bank = false }
    while true do
        local groups, chosen = {}, nil
        for _, g in ipairs(gem_list(0)) do
            if g.level >= 1 and g.level <= 8 and (mode == 2 or g.bind == mode) then
                local key = mode == 2 and g.name or g.name .. "|" .. g.bind
                local entry = groups[key] or { name = g.name, level = g.level, num = 0 }
                entry.num = entry.num + g.num
                groups[key] = entry
            end
        end
        for _, g in pairs(groups) do
            if g.num >= count and (not chosen or g.level < chosen.level or (g.level == chosen.level and g.name < chosen.name)) then chosen = g end
        end
        if not chosen then
            if not fetched.temp then
                fetched.temp = true
                if game(S.WindowVisible, nil, nil, "Packet_Temporary") ~= 1 then game(S.UiCall, { S.ui.Packet_Temporary_BtnClick, 0 }); Sleep(500) end
                local names = gem_names(gem_list(2))
                if #names > 0 then TempBank2Bag(table.concat(names, " ")) else game(S.CloseNamed, { S.windows.Packet_Temporary }) end
            elseif not fetched.bank then
                fetched.bank = true
                if open_bank() then
                    local names = gem_names(gem_list(1))
                    if #names > 0 then Bank_GetItem(table.concat(names, " ")) else CloseAllWindow() end
                end
            else
                PushColorMsg(title .. ":您已没有需要合成的宝石")
                break
            end
        else
            local tier = chosen.level <= 3 and 1 or chosen.level <= 6 and 2 or 3
            local talisman = ({ "低级宝石合成符", "高级宝石合成符", "超级宝石合成符" })[tier]
            if bag_count(talisman) == 0 then TempBank2Bag(talisman) end
            if bag_count(talisman) == 0 then Bank_GetItem(talisman) end
            if bag_count(talisman) == 0 then PushColorMsg(title .. ":您没有合成符了") break end
            if data("MONEY") + data("MONEY_JZ") < 5000 then
                PushDebugMessage(title .. ":金币不够,自动取钱！")
                Bank_GetMoney(50000)
                DebugStr(title .. ":金币不足")
            else
                local result = game(S.GemCombine, { mode, count, tier }, nil, chosen.name)
                if result == -1 then
                    game(S.CloseNamed, { S.windows.Gemcompose })
                    GoToSceneNPC("彭怀玉", 282, 321, 0)
                    Sleep(500)
                    DialogOptionClicked("#{BSLCYH_130529_133}", 1, 700)
                elseif result == 1 then
                    Sleep(100)
                else
                    DebugStr(chosen.name .. ":取出失败")
                end
            end
        end
        if GetTickCount() - start > 900000 then PushColorMsg(title .. ":超时") break end
        Sleep(200)
        DebugStr(title)
    end
    game(S.CloseNamed, { S.windows.Gemcompose })
    note("gemafter", "合成后的清包与存仓依赖原程序配置，未执行")
end

-- NPC 对话列表与帮会城市：依据 common.lua / common_2.lua 的 GetNPCEventList_Item、GetNPCEventListAllItem、
-- GetMyGuildCityName、IsMyGuildCity、GetSceneMainBranch、GoToGuild 反汇编。
function GetNPCEventList_Item(index)
    local ok, v = text_result(S.NpcEventItem, { math.floor(tonumber(index) or 0) })
    if ok ~= 1 then return "", "" end
    return text(v), ""
end
function GetNPCEventListAllItem()
    local n, v = text_result(S.NpcEventAll)
    return text(v), n or 0
end
local NO_GUILD = "你还没有加入帮会。"
function GetMyGuildCityName()
    DeleteDebugMsg(NO_GUILD)
    for _ = 1, 5 do
        local _, city = text_result(S.GuildInfo)
        if text(city) ~= "" then return text(city) end
        Sleep(1000)
        if IsInDebugMsg(NO_GUILD) then break end
    end
    return ""
end
function IsMyGuildCity()
    local city = GetMyGuildCityName()
    return city ~= "" and GetCurrentSceneName() == city
end
function MoveCallback_InMyGuild() return IsMyGuildCity() end
local branch_of = {}
for _, id in ipairs({ 1, 4, 5, 30, 31, 32, 33, 34, 35 }) do branch_of[id] = 1 end
for _, id in ipairs({ 2, 6, 7, 24, 25, 26, 27, 28, 29 }) do branch_of[id] = 2 end
branch_of[246] = 246
function GetSceneMainBranch(id) return branch_of[tonumber(id)] or LUOYANG_ID end
local guild_gates = {
    [1] = { "范纯粹", 322, 264, 1 }, [2] = { "范纯礼", 179, 121, 2 }, [246] = { "范纯祐", 190, 131, 246 },
}
-- 原程序没有总时限；这里加 3 分钟上限，避免卡在城市入口。原程序“离开非本帮城市”的帮会界面操作未接入。
function GoToGuild()
    local start = GetTickCount()
    while true do
        local city = GetMyGuildCityName()
        if city == "" then PushDebugMessage("未读到本帮城市（可能未加入帮会）"); return false end
        local name = GetCurrentSceneName()
        if name == city then return true end
        if name:find("神兵殿", 1, true) then PushDebugMessage("进入帮派城市错误:" .. name) end
        local gate = guild_gates[GetSceneMainBranch(GetSceneID())] or { "范纯仁", 237, 236, LUOYANG_ID }
        MoveToNPC(gate[1], gate[2], gate[3], gate[4])
        Sleep(600)
        local all = GetNPCEventListAllItem()
        if all:find("#{BHCS_090219_05}", 1, true) or all:find("查看帮会列表", 1, true) then
            if not (all:find("#{BHCS_090219_07}", 1, true) or all:find("进入本帮城市", 1, true)) then return false end
            QuestFrameOptionClicked_Item("进入本帮城市", 1, 600)
            QuestFrameOptionClicked_Item("#{BHCS_090219_07}", 1, 600)
        else
            Sleep(3000)
        end
        if GetTickCount() - start > 180000 then PushColorMsg("进入帮派城市超时"); return false end
        DebugStr("进入帮派城市")
    end
end

function MessageBox_Self2_OK_Clicked(sleep)
    local ok = ui("MessageBox_Self2_Ok_Clicked") == 1
    if ok and sleep then Sleep(sleep) end
    return ok
end

-- 原程序在“背包已满”时调用 Bag_DeleteItem / ClearBag 删除或清理物品；本程序不做删除类操作，改为停止并提示。
local function no_delete() error("背包需要清理：本程序不会自动删除或清理物品，请手动整理背包后重试") end
Bag_DeleteItem = no_delete
ClearBag = no_delete

-- 领取活跃好礼：依据 common.lua LingQuHuoYueHaoLi。每日 4 档按活跃度 1/50/150/450，最多尝试 4 次；
-- aGetZhou 为真时再按周活跃 1200/2000 领取两档周奖励。
local augury_need = { 1, 50, 150, 450 }
local function augury(name, param)
    GetLuaValue(string.format([[
        Clear_XSCRIPT()
            Set_XSCRIPT_Function_Name("%s")
            Set_XSCRIPT_ScriptID(889336)
            Set_XSCRIPT_Parameter(0,%d)
            Set_XSCRIPT_ParamCount(1)
        Send_XSCRIPT()
    ]], name, param))
end
function LingQuHuoYueHaoLi(weekly)
    DeleteDebugMsg("#{HYHL_101230_38}")
    for _ = 1, 4 do
        local box = game(S.ActiveBox) or -1
        if box < 1 or box > 4 then break end
        if data("TODAYACTIVEPOINT") >= augury_need[box] then augury("OnAugury", box) end
        Sleep(1000)
        if IsInDebugMsg("#{HYHL_101230_38}") then break end
    end
    if weekly then
        local week = data("WEEKACTIVEPOINT")
        if week >= 1200 then augury("OnAugury_week", 1) end
        if week >= 2000 then augury("OnAugury_week", 2) end
    end
end

-- 物品使用：依据 bag.lua 的 Bag:UseItemByName / Bag:LuaUseItem_DJ。只放行 game_snippets.hpp usableItems 里的名字。
local function use_item(name, bind, all)
    local index = S.items[trim(name)]
    if not index then error("该物品不在允许使用的名单中：" .. text(name)) end
    return game(S.UseBagItem, { index, bind or 0, all and 1 or 0 }) or -1
end
-- 原程序 Bag:EnumDaoJuItem 返回道具栏物品表，只作为 GetItemCount 的参数；这里的计数本来就只看道具栏。
function Bag.EnumDaoJuItem() return nil end
-- 材料栏 / 锦囊：返回标记表，GetItemCount 收到后改数对应容器。
local MATERIAL, TEMPBAG = { kind = 1 }, { kind = 2 }
function Bag.EnumCailiaoItem() return MATERIAL end
function Bag.EnumTempBagItem() return TEMPBAG end
function Bag.GetItemCount(_, name, _, _, list)
    if type(list) == "table" and list.kind then
        return watch_count(trim(name) .. (list.kind == 1 and "（材料栏）" or "（锦囊）"), game(S.BagCountIn, { list.kind }, nil, trim(name)) or 0)
    end
    return watch_count(trim(name), bag_count(name))
end
function Bag.UseItemByName(_, name, sleep)
    local ok = use_item(name, 0, false) >= 0
    if ok and sleep then Sleep(sleep) end
    return ok
end
-- aBind：1 只用非绑定，2 只用绑定（原程序默认 2）；每个匹配的格子都用一次。
function Bag.LuaUseItem_DJ(_, names, bind)
    local idx = -1
    for _, name in ipairs(names_of(names)) do
        local r = use_item(name, bind or 2, true)
        if r >= 0 then idx = r end
    end
    return idx
end
-- 原程序把剩余物品挪回锦囊（BagBankTempMove 拖动操作），本程序未接入，物品留在背包。
function Bag_Move2TempBank(names)
    note("move2temp", "剩余物品留在背包：移入锦囊尚未接入（" .. trim(names) .. "）")
    return 0
end

-- 任务记录：依据 common_2.lua GetPlayerMission_Item / GetMissionVariable / GetMissionComplete。
function GetPlayerMission_Item(memo)
    local slot, id, display = game(S.MissionFind, nil, nil, text(memo))
    return slot or -1, id or -1, display or -1
end
-- As common_2.lua: a slot outside 0..19 (GetPlayerMission's -1 for "not found") reads as -1, not an error.
function GetMissionVariable(slot, n)
    slot = math.floor(tonumber(slot) or -1)
    if slot < 0 or slot > 19 then return -1 end
    return game(S.MissionVar, { slot, math.floor(tonumber(n) or 0) }) or -1
end
function GetMissionComplete(slot) return GetMissionVariable(slot, 0) end
function GoToScene(x, y, scene, space) return MoveTo(x, y, scene, tonumber(space) or 2) end
-- 原程序下马后还会等坐骑状态消失、必要时放轻功；这里固定等 1 秒。
function Dismount(sleep)
    local result = game(S.Dismount, nil, nil, "坐骑：")
    if result == -1 then error("下坐骑接口尚未适配当前游戏版本，未使用任务物品") end
    if result ~= 1 then return true end
    Sleep(1000)
    if sleep then Sleep(sleep) end
    return false
end
-- 处于 state 时一直等，最多 timeout 秒；返回是否等过。
function PlayerStateTimeOut(state, timeout)
    local start, waited = GetTickCount(), false
    while true do
        Sleep(300)
        if game(S.PlayerState) ~= state then return waited end
        waited = true
        Sleep(80)
        if GetTickCount() - start > (tonumber(timeout) or 0) * 1000 then return waited end
    end
end
function GetPlayerVipLevel() return game(S.VipLevel) or 0 end
function MessageBox_Self_Text_Clicked(want, sleep)
    local index = S.msgbox[text(want)]
    if not index then error("该确认框文字不在允许名单中：" .. text(want)) end
    local ok = game(S.MsgBoxText, { index }) == 1
    if ok and sleep then Sleep(sleep) end
    return ok
end
function PlayerDataInit() end
function GlobalParam_tysz() end

-- 双倍经验：依据 functions.lua DoubleExp_Get / DoubleExp_Freeze。剩余时间读主菜单双倍计时（秒）。
local double_npcs = {
    { "刘健明", 242, 235, LUOYANG_ID }, { "沈澄", 250, 172, 1 }, { "洪大贵", 181, 139, 2 }, { "格鲁尔", 154, 121, 246 },
    { "宋三石", 163, 115, 850 }, { "宋三石", 448, 424, 762 }, { "宋三石", 448, 424, 772 }, { "宋三石", 448, 424, 773 },
}
local function double_timer() return game(S.DoubleTimer) or 0 end
-- 当前场景有对应 NPC 就用它，否则去苏州沈澄（原程序在跨服场景改用第 5 个，未接入）。
local function double_npc()
    local scene = GetSceneID()
    for _, n in ipairs(double_npcs) do if n[4] == scene then return n end end
    return double_npcs[2]
end
local function vip_double()
    GetLuaValue([[
        Clear_XSCRIPT()
            Set_XSCRIPT_Function_Name("OnUseVIP")
            Set_XSCRIPT_ScriptID(889644)
            Set_XSCRIPT_Parameter(0, 11)
            Set_XSCRIPT_ParamCount(1)
        Send_XSCRIPT()
    ]])
end
function DoubleExp_Get(minutes)
    PushDebugMessage("执行：领取双倍经验！")
    if GetPlayerVipLevel() >= 3 and double_timer() == 0 then
        vip_double()
        Sleep(1000)
        MessageBox_Self_Text_Clicked("解冻", 1500)
    end
    if minutes and double_timer() >= minutes * 60 then
        PushDebugMessage("领双：当前无需领取")
        return
    end
    local npc = double_npc()
    CloseAllWindow()
    for _ = 1, 4 do
        GoToSceneNPC(npc[1], npc[2], npc[3], npc[4])
        Sleep(500)
        if QuestFrameOptionClicked_Item("#{SBSJ_100726_02}", 1, 1500) then
            local s = GetNPCEventList_Item(0)
            if s:find("你没有在我这里冻结", 1, true) then
                TalkNpc(npc[1])
                Sleep(600)
                if QuestFrameOptionClicked_Item("我想领一小时双倍经验时间", 1, 1500) then
                    s = GetNPCEventList_Item(0)
                    if s:find("你没有这么多的时间可以领取了", 1, true) or s:find("达到可领取的上限", 1, true) or s:find("已经用完了", 1, true) then return end
                    QuestFrameOptionClicked_Item("是的，我要领取。", 1, 500)
                end
            else
                MessageBox_Self_OK_Clicked()
                Sleep(500)
            end
        end
        if minutes and double_timer() >= minutes * 60 then return end
    end
end
function DoubleExp_Freeze()
    if double_timer() == 0 then
        PushDebugMessage("冻双：无需冻结双倍经验")
        return
    end
    PushDebugMessage("执行：冻结双倍经验！")
    if GetPlayerVipLevel() >= 3 then
        local start, done = GetTickCount(), true
        DeleteDebugMsg("#{VIPTQ_120221_38}")
        while true do
            DebugStr("vip随身冻结双倍经验")
            vip_double()
            Sleep(1000)
            MessageBox_Self_Text_Clicked("确定进行冻结", 1000)
            if double_timer() == 0 then break end
            if GetTickCount() - start > 8000 then
                PushColorMsg("vip冻双：超时！")
                done = false
                break
            end
        end
        if done then return end
    end
    local npc = double_npc()
    CloseAllWindow()
    GoToSceneNPC(npc[1], npc[2], npc[3], npc[4])
    local start = GetTickCount()
    while true do
        GoToSceneNPC(npc[1], npc[2], npc[3], npc[4])
        if QuestFrameOptionClicked_Item("#{SBSJ_100726_01}", 1, 1500) then
            local s = GetNPCEventList_Item(0)
            if s:find("你现在没有已领取的双倍", 1, true) or s:find("已经处于冻结状态", 1, true) then
                PushDebugMessage("冻双：双倍经验已经冻结！")
                return
            end
            MessageBox_Self_OK_Clicked()
            Sleep(1500)
        end
        Sleep(500)
        if GetTickCount() - start > 60000 then
            PushColorMsg("冻双：超时！")
            return
        end
        DebugStr("冻结双倍经验")
    end
end

-- 回城：依据 common_2.lua GoBackCity / GoSafeScene。原程序读“通用”页的空闲地图名和坐标，这里读任务设置的场景号和坐标；
-- 未填写时去原程序的默认坐标（苏州 358,227）。场景 280 的定位符传送未接入。
function GoBackCity()
    local cfg = TaskConfig or {}
    local scene, x, y = tonumber(cfg.backcity_scene), tonumber(cfg.backcity_x), tonumber(cfg.backcity_y)
    local message = "前往安全地图"
    if not scene or scene < 0 or not x or x <= 0 or not y or y <= 0 then
        scene, x, y = 1, 358, 227
        message = "安全地图:您未在任务设置里填写安全坐标,前往默认坐标"
    end
    if near(scene, x, y, 3) then return end
    PushColorMsg(message)
    MoveTo(x, y, scene)
end

-- 下线：依据 common.lua OffLine。原程序记日志后调用退出；这里调用游戏的 QuitApplication，受“允许下线”开关控制。
function OffLine(_, reason)
    if reason then log("自动下线：" .. text(reason)) end
    game(S.QuitGame)
end

-- 领取周道具奖励用到的 EatBindItem：依据 bag.lua 同名函数，只实现“按名字使用绑定礼箱 + 批量使用确认”这一段；
-- 原函数随后自动使用宝石礼包、小还丹、真元和福降令等其它物品，并按“物品”页设置选活跃礼，这些未接入。
function EatBindItem(count, names)
    if not names or trim(names) == "" then error("EatBindItem 需要指定物品名（自动消化背包物品未接入）") end
    count = tonumber(count) or 20
    DeleteDebugMsg("#{OR_PILFER_LOCK_FLAG}")
    DeleteDebugMsg("#{ResultText_71}")
    for _ = 1, count do
        if Bag:LuaUseItem_DJ(names, 2) == -1 then break end
        if IsInDebugMsg("#{OR_PILFER_LOCK_FLAG}") or IsInDebugMsg("#{ResultText_71}") then break end
        Sleep(100)
        IsWindowVisible("Item_MultiUse", "Item_MultiUse_BuyMulti_Clicked()")
        DebugStr("消化物品.")
    end
end

-- 幸运快活三：原程序用一段界面脚本数 20 个头像中提示为空的个数。
function XingYunEmptyHeads() return game(S.XingYunCount) or -1 end

-- 物品汇总：只按名字汇总数量（原程序还区分绑定，但材料栏/仓库/锦囊的绑定状态读法未实测，暂不区分）。
-- where：bag / material / temp / bank；filter 是名字里必须包含的文字。仓库要先走到仓库 NPC 打开大仓库。
local item_kinds = { bag = 0, material = 1, temp = 2, bank = 3 }
local bank_cache = {}
function ItemTotals(where, filter, names)
    local kind = item_kinds[where]
    if not kind then error("未知物品容器：" .. text(where)) end
    if kind == 3 and bank_cache[filter] then return bank_cache[filter] end
    if kind == 3 and not open_bank() then return {} end
    local n, lines = text_result(S.ItemList, { kind }, nil, text(filter))
    if kind == 3 then CloseAllWindow() end
    local wanted = nil
    if names then wanted = {}; for _, v in ipairs(names) do wanted[v] = true end end
    local out = {}
    if (n or -1) >= 0 then
        for line in text(lines):gmatch("[^\n]+") do
            local name, num = line:match("^(.-)\t(%d+)$")
            if name and (not wanted or wanted[name]) then out[#out + 1] = { name = name, num = tonumber(num) } end
        end
    end
    if kind == 3 then bank_cache[filter] = out end
    return out
end
-- 按名字合并（同名累加），顺序保持先出现的在前，与原程序的合并函数一致。
function MergeItemTotals(into, from)
    for _, v in ipairs(from) do
        local hit = false
        for _, w in ipairs(into) do if w.name == v.name then w.num = w.num + v.num; hit = true; break end end
        if not hit then into[#into + 1] = { name = v.name, num = v.num } end
    end
    return into
end
-- 关闭窗口：只能关 game_snippets.hpp closableWindows 里的界面，其它的跳过。
function CloseWindow(name)
    local index = S.windows[trim(name)]
    if not index then note("close:" .. trim(name), "未接入关闭该界面：" .. trim(name)); return end
    game(S.CloseNamed, { index })
end
function IsDestination(x, y, scene, range) return near(tonumber(scene) or -1, tonumber(x), tonumber(y), tonumber(range) or 3) end
function PlayerAttackAttr() return game(S.AttackAttr) or -1 end
function CohesionCost() local n, money = game(S.CohesionCost); return n or -1, money or -1 end

-- 加工材料：依据 common.lua JiaGongCaiLiao。按材料栏里的材料名选生活技能配方 400–407 开始加工（最多 99 个）。
-- 原程序的 Bag:HasCaiLiaoByType 按物品类别判断；本程序按原规则列出的名字判断，“工艺材料”类别（配方 407）没有名字清单，未接入。
local sew_high = { "七彩的", "闪亮的", "无瑕的", "完美的", "发光的", "至尊" }
local sew_mid = { "普通的", "完好的", "破旧的" }
local sew_low = { "破损的", "残缺的", "坏掉的" }
local sew_part = { "黄骨", "地心", "玄丝", "天眼" }
local cast_part = { "刀柄", "枪杆", "剑鞘", "双棍", "扇骨", "环片" }
local function has_combo(all, prefixes, parts)
    for _, p in ipairs(prefixes) do for _, q in ipairs(parts) do if all:find(" " .. p .. q .. " ", 1, true) then return true end end end
    return false
end
function JiaGongCaiLiao()
    local all = " "
    local keys = { "皮毛" }
    for _, q in ipairs(sew_part) do keys[#keys + 1] = q end
    for _, q in ipairs(cast_part) do keys[#keys + 1] = q end
    for _, key in ipairs(keys) do
        for _, v in ipairs(ItemTotals("material", key)) do all = all .. v.name .. " " end
    end
    local recipe = nil
    if all:find(" 高级皮毛 ", 1, true) or all:find(" 中级皮毛 ", 1, true) or all:find(" 初级皮毛 ", 1, true) then recipe = 406
    elseif has_combo(all, sew_high, sew_part) then recipe = 405
    elseif has_combo(all, sew_mid, sew_part) then recipe = 404
    elseif has_combo(all, sew_low, sew_part) then recipe = 403
    elseif has_combo(all, sew_high, cast_part) then recipe = 402
    elseif has_combo(all, sew_mid, cast_part) then recipe = 401
    elseif has_combo(all, sew_low, cast_part) then recipe = 400 end
    if not recipe then return false end
    game(S.LifeCompose, { recipe })
    return true
end
function Bag.GetSpaceNum(_, kind) return game(S.BagSpace, { kind == 1 and 1 or 0 }) or 0 end
function Bag.PackUp() note("packup", "整理背包（Bag:PackUp）未接入，跳过") end
function GetTeamCount()
    local count = tonumber(game(S.TeamCount))
    if not count or count ~= count or count < 0 or count > 6 or count % 1 ~= 0 then
        error("无法读取有效的队伍人数；停止任务，避免误判队伍状态")
    end
    return count
end
function Player.GetState() return game(S.PlayerState) or -1 end

-- 合成武魂：道具栏里的御瑶盘/琉璃焰，读每件的“额外等级”和绑定状态（道具栏绑定状态可读）。
function WuhunItems()
    local n, lines = text_result(S.WuhunList, nil, nil, "御瑶盘 琉璃焰")
    local out = {}
    for line in text(lines):gmatch("[^\n]+") do
        local index, bind, level = line:match("^(%d+)\t(%-?%d+)\t(%-?%d+)$")
        if index then out[#out + 1] = { index = tonumber(index), bind = tonumber(bind), ext_level = tonumber(level) } end
    end
    return out
end
function WuhunCompound(a, b) return game(S.WuhunCompound, { a, b }, nil, "御瑶盘 琉璃焰") == 1 end

-- 任务描述：依据 common_2.lua GetMissionDesc / GetMissionDesc_NPC。描述里“#G小提示”之后的部分丢掉，
-- NPC 写成 {…x,y,场景,名字}。
function GetMissionDesc(memo)
    local ok, desc = text_result(S.MissionDesc, nil, nil, text(memo))
    desc = text(desc)
    if ok ~= 1 or desc == "" then PushDebugMessage(text(memo) .. "：没有获取到任务参数"); return "" end
    local cut = desc:find("#G小提示", 1, true)
    if cut then desc = desc:sub(1, cut - 1) end
    return desc
end
function GetMissionDesc_NPC(memo, hide)
    local desc = GetMissionDesc(memo)
    local x, y, scene, name = desc:match("{.-(%d+),(%d+),(%d+),(.-)}")
    x, y, scene = tonumber(x), tonumber(y), tonumber(scene)
    if not (x and y and scene and name) then
        if not hide then PushColorMsg(text(memo) .. "：没有解析到正确的npc参数") end
        return nil
    end
    if scene == 0 then scene = LUOYANG_ID end
    if name == "-1" then name = "" end
    return { x = x, y = y, sceneID = scene, name = name }
end
local guanshanhai = { [749] = true, [750] = true, [752] = true }
function IsGuanShanHaiScene(scene) return guanshanhai[tonumber(scene) or GetSceneID()] == true end
-- 原接口按物品动作按钮使用；本程序用同一个只放行名单内物品的使用操作。
function Bag.UseItemByName_click(self, name, sleep) return Bag.UseItemByName(self, name, sleep) end
-- 原接口在“武魂任务”确认框文字包含 text 时点确认；text 为空直接确认，非空时只放行 wuhunTexts 名单里的文字。
function WuhunQuest_Text_Clicked(want, sleep)
    want = text(want)
    if want == "" then
        IsWindowVisible("WuhunQuest", "WuhunQuest_Bn1Click()")
    else
        local index = S.wuhun[want]
        if not index then error("该确认框文字不在允许名单中：" .. want) end
        game(S.WuhunText, { index })
    end
    if sleep then Sleep(sleep) end
end
function UiButtonEnabled(index) return game(S.UiEnabled, { index }) == 1 end
function EquipAdjustAll() return game(S.EquipAdjust) or 0 end
function CityEnemyAsk() game(S.CityEnemyAsk) end
function CityEnemyHas(id) return game(S.CityEnemyHas, { id }) == 1 end
function CityOpenAddEnemy(id) game(S.OpenAddEnemy, { id }) end

-- 庄园：依据 common_2.lua IsZhuangYuanScene / GoOutZhuangYuan 与庄园养鱼/种植/采矿模块里的 ZYZZ_*、ZY_* 函数。
function IsZhuangYuanScene() return game(S.BieYeScene) == 1 end
-- 原程序进庄园时在入口附近按称号“庄园管事”找 NPC（扫描场景对象）；本程序不扫描对象，需要先手动进入庄园。
function GoToZhuangYuan()
    error("请先手动进入自己的庄园再运行（进庄园要扫描场景里的庄园管事，本程序不做对象扫描）")
end
function GoOutZhuangYuan()
    for _ = 1, 10 do
        if not IsZhuangYuanScene() then return end
        DebugStr("离开庄园")
        MoveToNPC("何闲庭", 125, 147, -1)
        Sleep(500)
        QuestFrameOptionClicked_Item("#{JYGZ_160523_07}", 1, 1000)
        QuestFrameOptionClicked_Item("#{JYGZ_160523_07}", 1, 1000)
        QuestFrameOptionClicked_Item("#{JYGZ_160523_97}", 1, 1000)
    end
end
function ZhuangYuanProduct(slot) local state, t = game(S.BieYeProduct, { slot }); return state or -1, t or 0 end
function ZhuangYuanAsk() game(S.BieYeAsk) end
function ZhuangYuanGardeners() local free, hired = game(S.BieYeGardeners); return free or 0, hired or 0 end

-- 科举：读考题界面的题目和 5 个选项。
function ExamRead()
    local ok, t = text_result(S.ExamRead)
    if ok ~= 1 then return "", "", "", "", "", "" end
    local parts = {}
    for piece in (text(t) .. "\t"):gmatch("(.-)\t") do parts[#parts + 1] = piece end
    return parts[1] or "", parts[2] or "", parts[3] or "", parts[4] or "", parts[5] or "", parts[6] or ""
end

-- 商店购买：每种商店一个固定的游戏内购买过程（见 game_snippets.hpp），这里按名字逐个调用。
local shop_ids = { huoyue = S.HuoYueBuy, honour = S.HonourBuy, guild = S.GuildShopBuy, t3 = S.T3ShopBuy, chonglou = S.ChongLouBuy, guishi = S.GuiShiBuy }
function ShopBuy(kind, name, count)
    if kind == "dividend" then return game(S.DividendBuy, nil, nil, trim(name)) or 0 end
    local id = shop_ids[kind]
    if not id then error("未知商店：" .. text(kind)) end
    return game(id, { math.floor(tonumber(count) or -1) }, nil, trim(name)) or 0
end
function HuoYueShopBuy(shop, name, count) return game(S.HuoYueBuy, { shop, math.floor(tonumber(count) or 0) }, nil, trim(name)) or 0 end
-- “名称*数量”清单：没有数量时 count 为 default。
function ParseItemList(list, default)
    local out = {}
    for item in text(list):gmatch("%S+") do
        local name, count = item:match("^(.-)%*(%d+)$")
        if name then out[#out + 1] = { name = name, count = tonumber(count) }
        else out[#out + 1] = { name = item, count = default } end
    end
    return out
end
function GoldGiftRead()
    local ok, t = text_result(S.GoldGiftRead)
    if ok ~= 1 then return "", "", "" end
    local a, b, c = (text(t) .. "\t\t\t"):match("^(.-)\t(.-)\t(.-)\t")
    return a or "", b or "", c or ""
end
function GoldGiftChoose(i) return game(S.GoldGiftChoose, { i }) == 1 end

-- 活动扫荡：依据 活动扫荡 模块 SaoDangHuoDong_xm 读的活动扫荡表与次数。
function HuoDongSweepCount() return game(S.HuoDongCount) or 0 end
function HuoDongSweepEnum(idx)
    local v=table.pack(game(S.HuoDongEnum, { idx }))
    local name="";for i=v.n,1,-1 do if type(v[i])=="string" then name=v[i];break end end
    return v[1] or 0, v[2] or 0, v[3] or 0, v[4] or 0, v[5] or 0, v[6] or 0, v[7] or 0, name
end
-- 开箱：只能用名字里带“宝箱”的物品（原程序 Bag:FindItem_vague("宝箱") 后逐个使用）。
function UseBoxItem(name) return (game(S.UseBoxItem, nil, nil, trim(name)) or -1) >= 0 end

-- 庄园血脉觉醒：读觉醒界面两个珍兽列表，返回“序号&文字 ”拼成的两段文字（与原程序一致）。
function AwakeRead()
    local ok, t = text_result(S.AwakeRead)
    if ok ~= 1 then return "", "" end
    local a, b = (text(t) .. "\t"):match("^(.-)\t(.-)\t")
    return a or "", b or ""
end
function AwakeSelect(list, idx) return game(S.AwakeAdd, { list, idx, 0 }) == 1 end
function AwakeInput(list) return game(S.AwakeAdd, { list, 0, 1 }) == 1 end

-- 绝学引导：按宗门天赋序号（0 起）请求加入对应宗门。
function AskSectOper(idx) game(S.SectOper, { idx }) end

-- NPC 商店购买：原程序 Shop_BuyItem 调注入的 meBuyShopItem；本程序按原程序红利商店同样的
-- NpcShop:BulkBuyItem(序号, 1, 0) 一次买一个，只放行 game_snippets.hpp shopItems 里的名字。
function Shop_BuyItem(name, num)
    local index = S.shop[trim(name)]
    if not index then error("该商店物品不在允许购买的名单中：" .. text(name)) end
    num = math.floor(tonumber(num) or 0)
    if num < 1 then PushColorMsg("购买物品:" .. text(name) .. " 数量有误!") return end
    for _ = 1, num do
        if (game(S.NpcShopBuy, { index }) or -1) < 0 then PushColorMsg("商店里没有：" .. text(name)) break end
        Sleep(300)
    end
    Sleep(500)
end

-- 任务模块：依据 common_2.lua GetPlayerMission 与 mission.lua 的 mission_* 函数。
-- 原程序判断“可接任务”用注入的 meIsMissionOutline（本程序无法复现），由各任务脚本改为到接任务 NPC 处看选项。
function GetPlayerMission(memo) return GetPlayerMission_Item(memo) end
function CollectMissionOutline() end
function mission_get_name(m)
    if m.option == nil or #m.option == 0 then return m.name end
    return m.option[1]
end
-- 原程序 bComplete 时先按原程序配置删除物品（Bag_DeleteItem），删除类不做，这里直接交任务。
function mission_complete_accept(option, next, complete, accept)
    Sleep(200)
    local ok = DialogOptionClicked(option, 1, 600)
    if next then QuestFrameNextClicked(500) end
    if complete then QuestFrameMissionComplete(nil, 500) end
    if accept then QuestFrameAcceptClicked(500) end
    return ok
end
function mission_accept(m)
    PushDebugMessage("接任务：" .. text(m.name))
    local p = m.param_accept
    for _ = 1, 3 do
        GoToSceneNPC(p.name, p.x, p.y, p.sceneID)
        local name = mission_get_name(m)
        mission_complete_accept(name, false, false, true)
        if GetPlayerMission(name) ~= -1 then return end
        PushColorMsg("再次尝试接任务：" .. name)
        Sleep(100)
    end
end
-- 原程序任务仍在且已完成时一直重试；这里最多 5 次。原程序每次还调注入的 meReliveHandle，未接入。
function mission_complete_talk_npc(m)
    PushDebugMessage("交任务：" .. text(m.name))
    local p = m.param_complete
    local accept = p.next_mission == nil
    local name = mission_get_name(m)
    for _ = 1, 5 do
        GoToSceneNPC(p.name, p.x, p.y, p.sceneID)
        if m.option and #m.option > 1 then
            for _, o in ipairs(m.option) do DialogOptionClicked(o, 1, 700) end
        end
        mission_complete_accept(m.option and m.option[1] or m.name, true, true, accept)
        local slot = GetPlayerMission(name)
        if slot == -1 or GetMissionVariable(slot, 0) ~= 1 then return end
        Sleep(200)
        DebugStr("交任务：" .. text(m.name))
    end
end

-- 出售：依据 bag.lua NpcShop_CheckPos / Bag_SellItem。走到当前主城的杂货商人打开商店，按名字（可选绑定筛选）
-- 逐格卖出；原程序还按物品类别和“能否出售”判断，类别读不到，只按名字。
local sell_npcs = {
    ["洛阳"] = { { "何生富", 349, 248, 0 }, { "何生财", 175, 293, 0 } },
    ["苏州"] = { { "张进宝", 184, 275, 1 }, { "张小泉", 344, 228, 1 } },
    ["大理"] = { { "何生金", 208, 177, 2 } },
    ["楼兰"] = { { "祝三思", 219, 129, 246 } },
    ["凤鸣镇"] = { { "高升瑞", 231, 83, 850, "看看你卖的东西" } },
    ["金陵"] = { { "高升瑞", 332, 370, 762, "看看你卖的东西" } },
}
local function nearest(table_, fallback)
    local map = (GetActiveSceneName():gsub("%d线$", ""))
    local list = table_[map]
    if not list then return fallback and table_[fallback][1] or nil end
    local pick, best = list[1], nil
    local x, y = Player_GetPos()
    for _, npc in ipairs(list) do
        local d = (npc[2] - x) * (npc[2] - x) + (npc[3] - y) * (npc[3] - y)
        if not best or d < best then pick, best = npc, d end
    end
    return pick
end
local function open_shop(npc)
    if game(S.WindowVisible, nil, nil, "Shop") == 1 then return true end
    GoToSceneNPC(npc[1], npc[2], npc[3], npc[4])
    if npc[5] then Sleep(500); QuestFrameOptionClicked_Item(npc[5], 1, 700) end
    for _ = 1, 20 do
        if game(S.WindowVisible, nil, nil, "Shop") == 1 then return true end
        Sleep(300)
    end
    PushColorMsg("商店没有打开：" .. npc[1])
    return false
end
-- items：{ { name = 名字, bind = 0/1/2 }, ... }；返回卖出的格数。
function SellBagItems(items)
    local any = false
    for _, v in ipairs(items) do if bag_count(v.name) > 0 then any = true break end end
    if not any then PushDebugMessage("出售:背包无可出售物品！") return 0 end
    local npc = nearest(sell_npcs)
    if not npc then PushDebugMessage("出售：当前不在主城") return 0 end
    if not open_shop(npc) then return 0 end
    local sold = 0
    for _, v in ipairs(items) do
        for _ = 1, 40 do
            local before = bag_count(v.name)
            if before == 0 or (game(S.BagSell, { v.bind or 0 }, nil, v.name) or -1) < 0 then break end
            sold = sold + 1
            PushDebugMessage("出售:" .. v.name)
            Sleep(300)
            if wait_change(function() return bag_count(v.name) end, before, 3000) == before then break end
        end
    end
    CloseAllWindow()
    return sold
end
-- 补给：依据 bag.lua Bag_BuyPlayerItem / Bag_BuyPetItem。want：{ { name = 名字, count = 要带的数量 }, ... }；
-- 药店与珍兽商店坐标取自原程序；只放行 game_snippets.hpp shopItems 里的名字。
local drug_npcs = { ["洛阳"] = { { "白萌生", 229, 307, 0 } }, ["苏州"] = { { "胡繁", 193, 252, 1 } }, ["大理"] = { { "卢三七", 105, 123, 2, "购买药品" } } }
local pet_npcs = {
    ["洛阳"] = { { "云渺渺", 275, 295, 0, "购买珍兽用品" } }, ["凤鸣镇"] = { { "云潇潇", 282, 41, 850, "购买珍兽用品" } },
    ["金陵"] = { { "云潇潇", 309, 459, 762, "购买珍兽用品" } }, ["大理"] = { { "云飘飘", 271, 133, 2, "购买珍兽用品" } },
    ["楼兰"] = { { "云兮兮", 109, 121, 246, "看看你卖的东西" } }, ["苏州"] = { { "云霏霏", 171, 238, 1, "购买珍兽用品" } },
}
function BuySupplies(want, pet)
    local need = {}
    for _, v in ipairs(want) do
        if not S.shop[v.name] then error("该商店物品不在允许购买的名单中：" .. text(v.name)) end
        local n = (tonumber(v.count) or 0) - bag_count(v.name)
        if n > 0 then need[#need + 1] = { name = v.name, num = n } end
    end
    if #need == 0 then return false end
    local npc = nearest(pet and pet_npcs or drug_npcs, "洛阳")
    if not open_shop(npc) then return false end
    DeleteDebugMsg("购买数量过大，包裹道具栏空位不足或包裹已满。")
    for _, v in ipairs(need) do
        Shop_BuyItem(v.name, v.num)
        if IsInDebugMsg("购买数量过大，包裹道具栏空位不足或包裹已满。") then PushColorMsg("补给：背包已满") break end
    end
    CloseAllWindow()
    return true
end

-- 修理：依据 fn修理装备.lua。装备栏 0–21 中耐久低于阈值的逐件修理；VIP6 以上远程修理，否则去苏州薛菲。
function EquipDurability(index, limit)
    local tid, def, left, name = game(S.EquipDur, { index, limit })
    return tid or 0, text(name), def or -1, left or 3
end
function EquipRepairAt(index, npc) game(S.EquipRepair, { index, npc and 1 or 0 }) end
function EquipRestoreCount(index, npc) return (game(S.EquipRestore, { index, npc and 1 or 0 }) or -1) >= 0 end
function WuhunLowLife(limit) local ok, name = game(S.WuhunLife, { limit }); return ok == 1, text(name) end
function WuhunAddLife() return (game(S.WuhunRepair) or -1) >= 0 end

-- 点修炼 / 点心法：依据 点修炼.lua、点心法.lua 读修炼秘籍与心法信息。
function XiuLianInfo(idx)
    local jj, lv, max, money, exp = game(S.XiuLianInfo, { idx })
    return jj or -1, lv or -1, max or -1, money or 0, exp or 0
end
function XinfaRead(i) local id, lv, ok = game(S.XinfaRead, { i }); return id or -1, lv or -1, ok == 1 end
function XinfaStudy(i) return game(S.XinfaStudy, { i }) == 1 end

-- 材料点金：mode 0 不绑定优先，1 只用绑定，2 只用不绑定，3 混用（绑定优先）。
function DianJin(mode, cloth, silver) return game(S.DianJin, { mode, cloth and 1 or 0, silver and 1 or 0 }) == 1 end
-- 名士赠礼：按礼物名找内置的英雄/礼物对，能送时打开赠礼界面。
function XZOpenGift(gift)
    local index = S.gifts[text(gift)]
    if not index then error("该礼物不在名士赠礼名单中：" .. text(gift)) end
    return game(S.XZGift, { index }) == 1
end
-- 宝石雕琢：1 已发起，0 材料栏没有该宝石，-1 没有对应等级的雕琢符，-2 名字里读不到等级。
function GemCarve(name) return game(S.GemCarve, nil, nil, trim(name)) or 0 end
-- 合成龙纹：读装备栏龙纹与背包里的龙纹（1）、龙纹玉灵（2）、铸纹玉（3）。
function LwScan()
    local eq, _, t = game(S.LwScan)
    local out = {}
    for line in text(t):gmatch("[^\n]+") do
        local i, kind, lv, bind = line:match("^(%d+)\t(%d+)\t(%d+)\t(%d+)$")
        if i then out[#out + 1] = { index = tonumber(i), kind = tonumber(kind), level = tonumber(lv), bind = tonumber(bind) } end
    end
    return eq == 1, out
end
function LwUnequip() return game(S.LwUnequip) == 1 end
function LwCombine(main, mat, stuff) return game(S.LwCombine, { main, mat, stuff }) == 1 end
function LwEquip(i) return game(S.LwEquip, { i }) == 1 end
