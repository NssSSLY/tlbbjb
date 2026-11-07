-- 武林印：由 dfz64.dll 字节码模块 任务/武林印.lua 静态还原
-- 模块 SHA256 b3c8236c18022de9f4a56c9d02cce7af17910ccb7ba0d23d81a1ceb37056276f；任务表（NPC、坐标、选项）、先交再做后接的顺序、取钱与买药品/杂货的条件按反汇编保持；原程序判断可接任务用注入的 meIsMissionOutline（本程序无法复现），改为走到接任务 NPC 处点任务名选项，每个任务在两次交/做之间只尝试一次；原程序买东西用注入的 meBuyShopItem，改为本程序固定的 NPC 商店购买（一次买一个，只放行金创药、白玉瓶）；失败的任务原程序会放弃（QuestFrameMissionAbnegate），本程序只提示不放弃；同一任务最多做 3 次、汇通天下内层最多 5 轮、主循环最多 200 轮。
local m_script_name = "武林印"
ScriptOnStart(m_script_name, false, false)
local tMenpai = {
    { name = "慧方", x = 96, y = 83, sceneID = 9, menpaiID = 0, menpaiName = "少林" },
    { name = "林岩", x = 98, y = 105, sceneID = 11, menpaiID = 1, menpaiName = "明教" },
    { name = "洪通", x = 91, y = 77, sceneID = 10, menpaiID = 2, menpaiName = "丐帮" },
    { name = "张中行", x = 78, y = 95, sceneID = 12, menpaiID = 3, menpaiName = "武当" },
    { name = "孟龙", x = 96, y = 88, sceneID = 15, menpaiID = 4, menpaiName = "峨嵋" },
    { name = "王彦", x = 96, y = 92, sceneID = 16, menpaiID = 5, menpaiName = "星宿" },
    { name = "本凡", x = 95, y = 88, sceneID = 13, menpaiID = 6, menpaiName = "天龙" },
    { name = "符敏仪", x = 95, y = 60, sceneID = 17, menpaiID = 7, menpaiName = "天山" },
    { name = "秦观", x = 119, y = 152, sceneID = 14, menpaiID = 8, menpaiName = "逍遥" },
    { name = "慕容胜", x = 68, y = 127, sceneID = 284, menpaiID = 10, menpaiName = "慕容" },
    { name = "唐清秋", x = 100, y = 64, sceneID = 615, menpaiID = 11, menpaiName = "唐门" },
    { name = "王玄风", x = 96, y = 98, sceneID = 678, menpaiID = 12, menpaiName = "鬼谷" },
    { name = "萧声咽", x = 160, y = 72, sceneID = 731, menpaiID = 13, menpaiName = "桃花岛" },
    { name = "七叔", x = 245, y = 191, sceneID = 824, menpaiID = 14, menpaiName = "绝情谷" },
    { name = "岳老三", x = 180, y = 181, sceneID = 987, menpaiID = 15, menpaiName = "恶人谷" },
}
local function GetMenpaiNPC()
    local nMenpai = Player:GetDataInt("MEMPAI")
    for i = 1, #tMenpai do
        if tMenpai[i].menpaiID == nMenpai then return tMenpai[i] end
    end
    return {}
end
local function Npc(name, x, y, sceneID) return { name = name, x = x, y = y, sceneID = sceneID } end
local function OnComplete(aParam) mission_complete_talk_npc(aParam) end
local function OnAccept(m)
    local p = m.param_accept or GetMenpaiNPC()
    if not p.x then return false end
    GoToSceneNPC(p.name, p.x, p.y, p.sceneID)
    if not DialogOptionClicked(m.name, 1, 800) then return false end
    QuestFrameAcceptClicked(700)
    return GetPlayerMission(m.name) ~= -1
end
local ZHOU, ZHU = Npc("周天师", 256, 274, LUOYANG_ID), Npc("祝富贵", 149, 121, 2)
local tMission = {
    { name = "青铜武林印之管理员邀请函", param_accept = ZHOU, param_complete = ZHU },
    { name = "汇通天下", param_accept = ZHU, param_complete = ZHU, OnAction = function(m)
        for _ = 1, 5 do
            DebugStr("执行任务:汇通天下")
            local nSlot = GetPlayerMission(m.name)
            if nSlot == -1 or GetMissionVariable(nSlot, 0) == 1 then
                CloseAllWindow()
                return
            end
            Bag:UseItemByName("天龙工资书", 1000)
            GoToSceneNPC("祝富贵", 149, 121, 2)
            DialogOptionClicked("红利商店", 1, 1000)
            Sleep(200)
        end
    end },
    { name = "青铜武林印之相助师门", param_accept = ZHU, OnComplete = function(m)
        local p = GetMenpaiNPC()
        if not p.x then return end
        GoToSceneNPC(p.name, p.x, p.y, p.sceneID)
        DialogOptionClicked(m.name, 1, 800)
        QuestFrameNextClicked(700)
        QuestFrameMissionComplete(nil, 700)
        QuestFrameAcceptClicked(700)
    end },
    { name = "青铜武林印之除恶务尽", param_complete = Npc("付劫生", 94, 201, 2), OnAction = function()
        if Player:GetMoney() + Player:GetMoney(2) < 1000 then Bank_GetMoney(1500) end
        GoToSceneNPC("卢三七", 105, 123, 2)
        Sleep(500)
        DialogOptionClicked("购买药品", 1, 100)
        Sleep(1000)
        Shop_BuyItem("金创药", 1)
    end },
    { name = "青铜武林印之惩凶打图", param_accept = Npc("付劫生", 94, 201, 2), param_complete = Npc("吴玠", 224, 226, 1) },
    { name = "裹银武林印之蹴鞠盛会", param_accept = ZHOU, param_complete = Npc("童贯", 303, 193, LUOYANG_ID), OnAction = function()
        if Player:GetMoney() < 1000 then Bank_GetMoney(1000) end
        GoToSceneNPC("芮福祥", 347, 284, LUOYANG_ID)
        Sleep(500)
        DialogOptionClicked("买卖杂货", 1, 1000)
        Shop_BuyItem("白玉瓶", 1)
    end },
    { name = "裹银武林印之贝叶经残片", param_accept = Npc("童贯", 303, 193, LUOYANG_ID), param_complete = Npc("诸葛孔亮", 290, 321, LUOYANG_ID) },
    { name = "裹银武林印之繁忙的漕运", param_accept = Npc("诸葛孔亮", 290, 321, LUOYANG_ID), param_complete = Npc("赵明诚", 325, 318, LUOYANG_ID) },
    { name = "裹银武林印之赚钱", param_accept = Npc("诸葛孔亮", 290, 321, LUOYANG_ID), param_complete = Npc("乔致广", 270, 255, LUOYANG_ID) },
    { name = "镏金武林印之云锦商行", param_accept = ZHOU, param_complete = Npc("付云伤", 356, 236, LUOYANG_ID) },
    { name = "镏金武林印之如虎添翼", param_accept = Npc("付云伤", 356, 236, LUOYANG_ID), param_complete = Npc("云姗姗", 355, 268, 1) },
    { name = "镏金武林印之神勇武魂", param_accept = Npc("云姗姗", 355, 268, 1), param_complete = Npc("无崖子", 140, 195, 2) },
    { name = "镏金武林印之潜心修炼", param_accept = Npc("无崖子", 140, 195, 2), param_complete = Npc("扫地神僧", 242, 31, 2) },
}
for _, m in ipairs(tMission) do m.OnComplete = m.OnComplete or OnComplete end
local tTried, tTimes = {}, {}
local function CompleteMissions()
    for _, m in ipairs(tMission) do
        local nSlot = GetPlayerMission(mission_get_name(m))
        if nSlot ~= -1 and GetMissionVariable(nSlot, 0) == 1 then
            DebugStr("交任务 " .. m.name, 2)
            m.is_complete = true
            m.OnComplete(m)
            return true
        end
    end
    return false
end
local function DoMissions()
    for _, m in ipairs(tMission) do
        local nSlot = GetPlayerMission(mission_get_name(m))
        if nSlot ~= -1 then
            local nState = GetMissionVariable(nSlot, 0)
            if nState == 0 and (tTimes[m.name] or 0) < 3 then
                tTimes[m.name] = (tTimes[m.name] or 0) + 1
                DebugStr("执行任务 " .. m.name, 2)
                if m.OnAction then m.OnAction(m) else m.OnComplete(m) end
                return true
            elseif nState == 0 then
                DebugStr("未能完成，可能需要手动完成：" .. m.name)
            elseif nState == 2 then
                -- 原规则放弃失败的任务；本程序不放弃，只提示。
                DebugStr("任务失败，请手动放弃：" .. m.name)
            end
        end
    end
    return false
end
local function AcceptMissions()
    local nScene, bAccept = -1, false
    for _, m in ipairs(tMission) do
        local p = m.param_accept or GetMenpaiNPC()
        if not m.is_complete and not tTried[m.name] and p.sceneID and (nScene == -1 or p.sceneID == nScene)
            and GetPlayerMission(mission_get_name(m)) == -1 then
            tTried[m.name] = true
            DebugStr("接任务 " .. m.name, 2)
            if OnAccept(m) then
                nScene = p.sceneID
                bAccept = true
            end
        end
    end
    return bAccept
end
function _SMain()
    LoadScript("mission")
    local nStart = 0
    for _ = 1, 200 do
        if CompleteMissions() or DoMissions() then
            tTried = {}
        elseif not AcceptMissions() then
            if nStart <= 2 then
                for _, szName in ipairs({ "青铜武林印之管理员邀请函", "裹银武林印之蹴鞠盛会", "镏金武林印之云锦商行" }) do
                    GoToSceneNPC(ZHOU.name, ZHOU.x, ZHOU.y, ZHOU.sceneID)
                    DialogOptionClicked(szName, 1, 700)
                    QuestFrameAcceptClicked(500)
                end
                nStart = nStart + 1
                tTried = {}
            else
                PushColorMsg("武林印：无任务可接")
                break
            end
        end
        Sleep(100)
        DebugStr("武林印 " .. nStart, 1)
    end
    for _, szItem in ipairs({ "青铜武林印", "裹银武林印（1级）", "镏金武林印（1级）", "裹银武林印（2级）", "镏金武林印（2级）",
        "裹银武林印（3级）", "镏金武林印（3级）", "裹银武林印（4级）", "镏金武林印（4级）", "裹银武林印（5级）", "镏金武林印（5级）",
        "裹银武林印（6级）", "镏金武林印（6级）" }) do
        Bag:UseItemByName_click(szItem, 1000)
    end
end
_SMain()
ScriptOnStop(m_script_name)
