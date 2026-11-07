-- 反编译自 dfz64.dll 内嵌字节码 002b44c6（unluac 2025-12-23；仅供分析）
PushDebugMessage("鉴定：自动鉴定武器资质")

function _SMain()
  local nNum = GetLuaValue("return DataPool:GetBaseBag_Num();", "n")
  for i = 0, nNum - 1 do
    local isWQ = GetLuaValue(fmt([[
                    local idx = %d
                    local theAction,bLocked = PlayerPackage:EnumItem('base', idx);
                    if theAction:GetID() ~= 0 then
                       if LifeAbility : Get_Equip_TableIndex(idx) ~= -1 then 
                            if LifeAbility:Get_Equip_Point(idx) == 0 then return 1 end
                       end 
                    end
                    return 0
                ]], i), "b")
    if isWQ then
      GetLuaValue(fmt([[
                        Clear_XSCRIPT();
			            	Set_XSCRIPT_Function_Name("FinishAdjust");
			            	Set_XSCRIPT_ScriptID(809261);
			            	Set_XSCRIPT_Parameter(0,%d);
			            	Set_XSCRIPT_ParamCount(1);
			            Send_XSCRIPT();                       
                    ]], i))
      Sleep(50)
    end
  end
end

_SMain()
