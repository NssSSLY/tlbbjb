function _SMain()
    --GetLuaValue("setmetatable(_G, {__index=PlayerQuicklyEnter_Env});PlayerQuicklyEnter_Clicked(15)","",0)
    Sleep(1000)
    GetLuaValue([[
		Clear_XSCRIPT()
			Set_XSCRIPT_Function_Name("CheckTodaySign")
			Set_XSCRIPT_ScriptID(891106)
			Set_XSCRIPT_ParamCount(0)
		Send_XSCRIPT()

	]], "", 0)
    Sleep(1000)
    for i = 1, 5 do
        local strText =
            [[
				Clear_XSCRIPT()
					Set_XSCRIPT_Function_Name("GetPrize")
					Set_XSCRIPT_ScriptID(891106)
					Set_XSCRIPT_Parameter(0, %d)
					Set_XSCRIPT_ParamCount(1)
				Send_XSCRIPT()
			]]
        strText = string.format(strText, i)
        GetLuaValue(strText, "", 0)
        Sleep(200)
    end

    CloseWindow("Fuli_MonthlySign")
end

_SMain()
