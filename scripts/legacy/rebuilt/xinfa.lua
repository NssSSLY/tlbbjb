-- 点心法：由 dfz64.dll 字节码模块 功能/点心法.lua 静态还原
-- 模块 SHA256 44e8bd7db3c9fb968b4c061cb33d7d37992ec3b9d268ff5f82aa1dedc58b7c84；门派心法 NPC 坐标、取钱/存钱、目标等级判断、金币与经验检查、确认框文字与 5 分钟超时按反汇编保持；原程序设置页的 8 个目标等级改为任务设置（默认 0，表示不升）。
local m_script_name = "点心法"
ScriptOnStart(m_script_name)
local cfg = TaskConfig or {}
local tLevel = {}
for i = 1, 8 do tLevel[i] = tonumber(cfg["xf_" .. i]) or 0 end
local tName = { [0] = "少林", [1] = "明教", [2] = "丐帮", [3] = "武当", [4] = "峨嵋", [5] = "星宿", [6] = "天龙", [7] = "天山", [8] = "逍遥",
    [10] = "慕容", [11] = "唐门", [12] = "鬼谷", [13] = "桃花岛", [14] = "绝情谷", [15] = "恶人谷" }
local tNpc = {
    ["少林"] = { name = "玄难", x = 91, y = 72, sceneID = 9 }, ["明教"] = { name = "庞万春", x = 108, y = 59, sceneID = 11 },
    ["丐帮"] = { name = "奚三祁", x = 95, y = 99, sceneID = 10 }, ["武当"] = { name = "俞远山", x = 82, y = 85, sceneID = 12 },
    ["峨嵋"] = { name = "崔绿华", x = 98, y = 52, sceneID = 15 }, ["星宿"] = { name = "施全", x = 87, y = 70, sceneID = 16 },
    ["天龙"] = { name = "本观", x = 98, y = 66, sceneID = 13 }, ["天山"] = { name = "兰剑", x = 88, y = 44, sceneID = 17 },
    ["逍遥"] = { name = "康广陵", x = 124, y = 142, sceneID = 14 }, ["慕容"] = { name = "慕容青山", x = 48, y = 134, sceneID = 284 },
    ["唐门"] = { name = "唐岳冲", x = 38, y = 75, sceneID = 615 }, ["鬼谷"] = { name = "李继隆", x = 91, y = 55, sceneID = 678 },
    ["桃花岛"] = { name = "燕返", x = 205, y = 65, sceneID = 731 }, ["绝情谷"] = { name = "云骁", x = 230, y = 170, sceneID = 824 },
    ["恶人谷"] = { name = "叶二娘", x = 186, y = 120, sceneID = 987 },
}
function _SMain()
    local tSelf = tNpc[tName[Player:GetDataInt("MEMPAI")] or ""]
    if not tSelf then
        PushColorMsg("点心法：门派信息不正确")
        return
    end
    PushColorMsg("点心法：取钱")
    Bank_GetMoney(-1)
    CloseAllWindow()
    local nStart = GetTickCount()
    while true do
        GoToScene(tSelf.x, tSelf.y, tSelf.sceneID)
        local bDone = false
        for i = 1, #tLevel do
            local nId, nLevel, bCan = XinfaRead(i)
            if nId >= 0 and nLevel < tLevel[i] and bCan then
                bDone = true
                PushDebugMessage("点击第" .. i .. "本心法,当前等级" .. nLevel)
                XinfaStudy(i)
                Sleep(300)
                MessageBox_Self_Text_Clicked("需要使用角色自身经验", 800)
            end
        end
        if not bDone then
            PushColorMsg("点心法：没有心法可升级,检查经验或金币")
            break
        end
        if GetTickCount() - nStart > 300000 then
            PushColorMsg("点心法：超时")
            break
        end
        Sleep(100)
        DebugStr(m_script_name)
    end
    PushColorMsg("点心法：存钱")
    Bank_SaveMoney(0)
end
_SMain()
