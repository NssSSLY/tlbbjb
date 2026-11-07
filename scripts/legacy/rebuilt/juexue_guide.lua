-- 绝学引导：由 dfz64.dll 字节码模块 任务/绝学引导.lua 静态还原
-- 模块 SHA256 aa031c46582fbb29cf759fcd3977cfde4f7b27583bdae967b6bf9d8eeaff708d；NPC 坐标、对话选项、任务变量判断与先交后接的顺序按反汇编保持；原程序判断可接任务用注入的 meIsMissionOutline（本程序无法复现），改为走到门派 NPC 处按顺序点三个任务的接取选项；原程序按物品类型“镇派秘宝”找背包物品使用，游戏里读物品类型的接口没有依据，改为走到使用地点后提示手动使用并结束；第三个任务按宗门列表顺序请求加入（原规则如此），这一步只有在任务设置里允许时才做；各循环最多 20 轮、主循环最多 30 轮。
local m_script_name = "绝学引导"
ScriptOnStart(m_script_name)
local cfg = TaskConfig or {}
local bChoose = cfg.jxyd_choose == true
local tMenpai = {
    [0] = { name = "灵门禅师", x = 97, y = 50, sceneID = 883, mpname = "少林", mis2 = { x = 96, y = 59 }, mis4 = { x = 134, y = 55, name = "灵源" } },
    [1] = { name = "拂多诞", x = 96, y = 52, sceneID = 887, mpname = "明教", mis2 = { x = 55, y = 93 }, mis4 = { x = 131, y = 55, name = "呼禄" } },
    [2] = { name = "庄信方", x = 96, y = 47, sceneID = 891, mpname = "丐帮", mis2 = { x = 139, y = 136 }, mis4 = { x = 131, y = 56, name = "穆天白" } },
    [3] = { name = "李天师", x = 96, y = 44, sceneID = 886, mpname = "武当", mis2 = { x = 56, y = 156 }, mis4 = { x = 131, y = 55, name = "九皋处士" } },
    [4] = { name = "孟玉清", x = 96, y = 48, sceneID = 890, mpname = "峨嵋", mis2 = { x = 96, y = 165 }, mis4 = { x = 131, y = 56, name = "孟听晓" } },
    [5] = { name = "黎牵机", x = 97, y = 46, sceneID = 885, mpname = "星宿", mis2 = { x = 96, y = 59 }, mis4 = { x = 127, y = 50, name = "黎枯春" } },
    [6] = { name = "段思廉", x = 96, y = 50, sceneID = 889, mpname = "天龙", mis2 = { x = 95, y = 159 }, mis4 = { x = 133, y = 54, name = "段寿辉" } },
    [7] = { name = "童缈月", x = 96, y = 47, sceneID = 884, mpname = "天山", mis2 = { x = 96, y = 55 }, mis4 = { x = 127, y = 54, name = "童恨星" } },
    [8] = { name = "北冥客", x = 95, y = 54, sceneID = 888, mpname = "逍遥", mis2 = { x = 139, y = 139 }, mis4 = { x = 131, y = 55, name = "忘忧君" } },
    [10] = { name = "慕容龙岳", x = 96, y = 46, sceneID = 892, mpname = "慕容", mis2 = { x = 57, y = 92 }, mis4 = { x = 124, y = 53, name = "慕容恒昌" } },
    [11] = { name = "唐岳平", x = 96, y = 38, sceneID = 893, mpname = "唐门", mis2 = { x = 52, y = 158 }, mis4 = { x = 111, y = 42, name = "唐岳戈" } },
    [12] = { name = "文始君", x = 96, y = 46, sceneID = 894, mpname = "鬼谷", mis2 = { x = 96, y = 164 }, mis4 = { x = 132, y = 56, name = "寒泉子" } },
    [13] = { name = "黄落兮", x = 96, y = 40, sceneID = 895, mpname = "桃花岛", mis2 = { x = 56, y = 93 }, mis4 = { x = 133, y = 54, name = "杨柳风" } },
    [14] = { name = "穆世瑜", x = 96, y = 50, sceneID = 896, mpname = "绝情谷", mis2 = { x = 96, y = 58 }, mis4 = { x = 132, y = 56, name = "志武" } },
    [15] = { name = "山都", x = 96, y = 50, sceneID = 988, mpname = "恶人谷", mis2 = { x = 96, y = 109 }, mis4 = { x = 130, y = 55, name = "山鸮" } },
}
local tSelf = tMenpai[Player:GetDataInt("MEMPAI")]
local function GoMenpaiNPC() GoToSceneNPC(tSelf.name, tSelf.x, tSelf.y, tSelf.sceneID) end
local function Complete(szOption)
    QuestFrameOptionClicked_Item(szOption, 1, 1000)
    QuestFrameMissionComplete(nil, 800)
    QuestFrameAcceptClicked(1000)
end
-- 返回 false 表示需要用户处理，整个任务结束。
function JXYD_Mission1()
    for _ = 1, 20 do
        local nSlot = GetPlayerMission("初识秘境济师门")
        if nSlot == -1 then break end
        GoMenpaiNPC()
        if GetMissionVariable(nSlot, 0) == 1 then
            Complete("#{ZMYD_230801_269}")
        else
            for _, k in ipairs({ 269, 285, 273, 287, 289, 291 }) do
                QuestFrameOptionClicked_Item("#{ZMYD_230801_" .. k .. "}", 1, 1000)
            end
        end
        Sleep(500)
        DebugStr("初识秘境济师门")
    end
    return true
end
function JXYD_Mission2()
    for _ = 1, 20 do
        local nSlot = GetPlayerMission("开灵除尘秘宝现")
        if nSlot == -1 then break end
        if GetMissionVariable(nSlot, 0) == 1 then
            GoMenpaiNPC()
            Complete("#{ZMYD_230801_354}")
        else
            GoToScene(tSelf.mis2.x, tSelf.mis2.y, tSelf.sceneID)
            -- 原规则：Bag:SearchItemType("镇派秘宝") 找到后下马使用，再等读条结束。
            PushColorMsg(m_script_name .. "：已到使用地点，请手动使用背包里的镇派秘宝，完成后再运行本任务")
            return false
        end
        Sleep(500)
        DebugStr("开灵除尘秘宝现")
    end
    return true
end
function JXYD_Mission3()
    -- 原规则开始时先用一次镇派秘宝（按物品类型找），未接入。
    for _ = 1, 20 do
        local nSlot = GetPlayerMission("绝学问武意纵横")
        if nSlot == -1 then break end
        if GetMissionVariable(nSlot, 0) == 1 then
            GoToSceneNPC(tSelf.mis4.name, tSelf.mis4.x, tSelf.mis4.y, tSelf.sceneID)
            Complete("#{ZMYD_230801_641}")
        else
            if not bChoose then
                PushColorMsg(m_script_name .. "：这一步要选择宗门，未在设置里允许，请手动选择后再运行")
                return false
            end
            for i = 1, 10 do
                if GetMissionVariable(nSlot, 0) ~= 0 then break end
                AskSectOper(i - 1)
                Sleep(500)
            end
        end
        Sleep(500)
        DebugStr("绝学问武意纵横")
    end
    CloseAllWindow()
    return true
end
local tMission = {
    { name = "初识秘境济师门", doMis = JXYD_Mission1, option = "#{ZMYD_230801_269}" },
    { name = "开灵除尘秘宝现", doMis = JXYD_Mission2, option = "#{ZMYD_230801_354}" },
    { name = "绝学问武意纵横", doMis = JXYD_Mission3, option = "#{ZMYD_230801_641}" },
}
-- 返回：nil 没有进行中的任务；true 做过一个；false 需要用户处理。
function JXYD_DoMission()
    for _, v in ipairs(tMission) do
        if GetPlayerMission(v.name) ~= -1 then return v.doMis() end
    end
    return nil
end
function JXYD_AcceptMission()
    GoMenpaiNPC()
    for _, v in ipairs(tMission) do
        if QuestFrameOptionClicked_Item(v.option, 1, 1000) then
            QuestFrameAcceptClicked(1000)
            return true
        end
    end
    return false
end
function _SMain()
    LoadScript("mission")
    if not tSelf then
        PushColorMsg(m_script_name .. "：当前门派没有引导任务数据")
        return
    end
    for _ = 1, 30 do
        local bDone = JXYD_DoMission()
        if bDone == false then return end
        if bDone == nil and not JXYD_AcceptMission() then
            PushColorMsg("完成引导任务")
            return
        end
        Sleep(500)
        DebugStr(m_script_name)
    end
end
_SMain()
ScriptOnStop(m_script_name)
