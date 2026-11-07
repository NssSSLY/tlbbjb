-- 材料点金：由 dfz64.dll 字节码模块 功能/材料点金.lua 静态还原
-- 模块 SHA256 d96f2adefe76973b1ddc5f016e3fe3744fe40d1c53ff10ae188a8d3f9bfacd01；NPC、对话选项、四种绑定方式的选料规则与 5 次点金按反汇编保持；原程序设置页的点金模式与材料勾选改为任务设置。
local m_script_name = "材料点金"
ScriptOnStart(m_script_name, false, false)
local cfg = TaskConfig or {}
local mode = math.max(0, math.min(3, math.floor(tonumber(cfg.dj_mode) or 0)))
local dmb, dmy = cfg.dj_mianbu == true, cfg.dj_miyin == true
function _SMain()
    local szName = ""
    if dmb then szName = szName .. " 3级棉布 " end
    if dmy then szName = szName .. " 3级秘银 " end
    if szName == "" then
        PushColorMsg(m_script_name .. ":请勾选物品名称")
        return
    end
    Bank_GetItem("点金玉" .. szName)
    TempBank2Bag("点金玉" .. szName)
    GoToSceneNPC("彭怀玉", 282, 321, LUOYANG_ID)
    Sleep(500)
    QuestFrameOptionClicked_Item("#{ZZQH_180929_1}", 1, 700)
    for _ = 1, 5 do
        if DianJin(mode, dmb, dmy) then Sleep(100) end
    end
end
_SMain()
ScriptOnStop(m_script_name)
