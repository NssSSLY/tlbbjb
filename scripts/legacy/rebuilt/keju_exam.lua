-- 科举答题：由 dfz64.dll 字节码模块 其他/科举答题.lua 静态还原
-- 模块 SHA256 9d771c9aa339559fc4546f7bd588abd418eba94559cb5f3e5fe317000f59cf36；题库匹配、选项判断、考官位置解析与结束条件按反汇编保持；题库来自原程序 数据/科举.lua（8424 题，见 data/keju_bank.lua）；
-- 原规则找考官时会切换分线，本程序不切换；报名要花钱，需要打开“允许支付”。
local m_script_name = "科举答题"
ScriptOnStart(m_script_name, false, false)
local tUnknown = {}
local function Click(nIndex)
    GetLuaValue(string.format("setmetatable(_G, {__index = Examination_Env});Examination_Button_Clicked(%d)", nIndex))
    Sleep(500)
end
local function Answer()
    local q, a1, a2, a3, a4, a5 = ExamRead()
    if string.find(q, "下列答案中只有1个是正确的，请选择", nil, true) then
        q = string.gsub(q, "\n下列答案中只有1个是正确的，请选择", "")
        local n = -1
        for k, v in pairs(Q) do
            if string.find(q, v, nil, true) then
                if A[k] == a1 then n = 1; break
                elseif A[k] == a2 then n = 2; break
                elseif A[k] == a3 then n = 3; break end
            end
        end
        if n ~= -1 then
            Click(n)
        else
            PushDebugMessage(string.format(m_script_name .. ":没有题目[%s]对应的答案", q))
            local bNew = true
            for i = 1, #tUnknown do if tUnknown[i] == q then bNew = false end end
            if bNew then
                table.insert(tUnknown, q)
                LogMsg("题目：" .. q .. " 选项1：" .. a1 .. " 选项2：" .. a2 .. " 选项3：" .. a3)
            end
        end
    elseif string.find(q, "想要来参加科举考试啊？", nil, true) then
        IsWindowVisible("Examination", "Examination_Button_Clicked(1)")
        Sleep(500)
    end
end
function _SMain()
    LoadScript("科举.lua")
    if Q == nil or A == nil then
        PushColorMsg("科举答题：加载题库失败！")
        return
    end
    local x, y, szName = 230, 240, "林举贤"
    -- 闭环保护：考题界面没开、考官对话连续 120 轮相同就停止（原规则没有上限）。
    local guard = NoProgress(m_script_name, 120)
    while true do
        if IsWindowVisible("Examination") == false then
            local szText = GetNPCEventList_Item(0)
            guard(szText)
            if string.find(szText, "金钱不足", nil, true) then
                PushColorMsg("金钱不足，结束脚本!")
                break
            elseif string.find(szText, "恭喜您", nil, true) then
                PushDebugMessage(m_script_name .. ":州试已完成!")
                break
            elseif string.find(szText, "考官位置在", nil, true) then
                local nx, ny, szAim = string.match(szText, "#{_INFOAIM(%d+),(%d+),%d+,(.+)}")
                if nx and ny and szAim then
                    x, y, szName = tonumber(nx), tonumber(ny), szAim
                    PushDebugMessage(string.format("考官:%d,%d,%s", x, y, szName))
                end
            elseif string.find(szText, "对不起，您答错了", nil, true) then
                QuestFrameOptionClicked_Item("准备好了，开始吧······", 1, 800)
            elseif string.find(szText, "请等待下一轮的科举活动。", nil, true) then
                DebugStr("等待复试", 2)
            end
            GoToSceneNPC(szName, x, y, 2)
            -- 原规则这里还会切换分线（ChangeSceneLine）去找考官；本程序不切换分线。
            Sleep(500)
            DialogOptionClicked("科举初试", 1, 600)
        else
            Answer()
        end
        Sleep(200)
        DebugStr(m_script_name)
    end
    Q = nil
    A = nil
end
_SMain()
ScriptOnStop(m_script_name)
