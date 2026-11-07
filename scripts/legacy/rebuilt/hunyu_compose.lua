-- 合成魂玉：由 dfz64.dll 字节码模块 功能/合成魂玉.lua 静态还原
-- 模块 SHA256 7dbfc511f622e223716c5ccf94887c964cc640bb973053e2f6011cba24228b63；调用、参数、等待和循环按反汇编逐条保持。原程序“ZH/dxk8”设置项（合成天魂玉）改为任务设置里的勾选框；取仓库/锦囊时的绑定筛选参数未接入。
local m_script_name = "合成魂玉"
ScriptOnStart(m_script_name, true, false)
local cfg = { thy = (TaskConfig or {}).hunyu_tian == true, dhy = false }
function _SMain()
    TempBank2Bag("命魂玉 地魂玉 天魂玉", 2)
    Bank_GetItem("命魂玉 地魂玉 天魂玉", -1, 2, 1, true)
    local nStart = -1
    if not cfg.thy then cfg.dhy = true end
    while true do
        Sleep(200)
        local nMing = Bag:GetItemCount("命魂玉")
        local nDi = Bag:GetItemCount("地魂玉")
        local nTian = Bag:GetItemCount("天魂玉")
        if cfg.dhy and nMing < 5 then
            PushColorMsg("合成地魂玉:已经没有命魂玉！")
            break
        elseif cfg.thy and nMing < 5 and nDi < 5 then
            PushColorMsg("合成天魂玉:已经没有命魂玉、地魂玉！")
            break
        end
        GoToSceneNPC("逍遥子", 247, 217, 850)
        if nStart == -1 then nStart = GetTickCount() end
        QuestFrameOptionClicked_Item("#{JXSQ_170804_07}", 1, 800)
        if nMing >= 5 then QuestFrameOptionClicked_Item("#{JXSQ_170804_132}", 1, 600) end
        if nDi >= 5 and cfg.thy then QuestFrameOptionClicked_Item("#{JXSQ_170804_133}", 1, 600) end
        IsWindowVisible("ShenqiSX_HY", "ShenqiSX_HY_OK_Clicked()")
        if GetTickCount() - nStart > 120000 then
            PushColorMsg(m_script_name .. ":执行超时")
            break
        end
        DebugStr("合成魂玉")
    end
end
_SMain()
ScriptOnStop(m_script_name, false)
