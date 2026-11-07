-- 找回经验：由 dfz64.dll 字节码模块 其他/找回经验.lua 静态还原
-- 模块 SHA256 89d658cc54db190da26abcfbbedee3352447372860d5f202786d8550ac0daa7c；调用、参数、等待和次数按反汇编逐条保持。
-- 原规则用金币找回经验，并在确认框出现时点击确认；系统提示提前结束尚未接入，按原上限 3 次执行。
function _SMain()
    PushDebugMessage("经验找回")
    DeleteDebugMsg("#{XTZY_171213_13}")
    DeleteDebugMsg("#{XTZY_171213_24}")
    DeleteDebugMsg("#{XTZY_171213_31}")
    for i = 1, 3 do
        GetLuaValue([[
                Clear_XSCRIPT();
                Set_XSCRIPT_Function_Name("GetExp_ByMoney");
                Set_XSCRIPT_ScriptID(892659); 
                Set_XSCRIPT_Parameter(0, 0 )  
                Set_XSCRIPT_ParamCount(1);
                Send_XSCRIPT();
                ]])
        Sleep(1500)
        IsWindowVisible("WuhunQuest", "WuhunQuest_Bn1Click();")
        Sleep(1500)
        if IsInDebugMsg("#{XTZY_171213_13}") or IsInDebugMsg("#{XTZY_171213_24}") or IsInDebugMsg("#{XTZY_171213_31}") then break end
    end
end
_SMain()
