-- 反编译自 dfz64.dll 内嵌字节码 0034b22d（unluac 2025-12-23；仅供分析）
local m_script_name = "材料点金"
ScriptOnStart(m_script_name, false, false)
g_config["材料点金"] = {}
g_config["材料点金"]["点金模式"] = GetConfigCommbox("设置", "材料点金模式")
g_config["材料点金"]["点棉布"] = GetConfigBool("设置", "材料点金棉布")
g_config["材料点金"].点秘银 = GetConfigBool("设置", "材料点金秘银")
local m_param = {}
m_param.mode = g_config["材料点金"]["点金模式"].sel
m_param.dmb = g_config["材料点金"]["点棉布"]
m_param.dmy = g_config["材料点金"].点秘银

function _SMain()
  local tickOut = GetTickCount()
  local clName = ""
  if m_param.dmb then
    clName = clName .. " 3级棉布 "
  end
  if m_param.dmy then
    clName = clName .. " 3级秘银 "
  end
  if "" == clName then
    PushColorMsg(m_script_name .. ":请勾选物品名称")
    return
  end
  local itemName = "点金玉"
  Bank_GetItem(itemName .. clName)
  TempBank2Bag(itemName .. clName)
  GoToSceneNPC("彭怀玉", 282, 321, LUOYANG_ID)
  Sleep(500)
  QuestFrameOptionClicked_Item("#{ZZQH_180929_1}", 1, 700)
  for i = 1, 5 do
    local djyPos = -1
    local clPos = -1
    local objDjy = Bag:FindItemInfo("点金玉")
    local objCl = Bag:SearchItemName(clName)
    local djyUnbind = GetTableFieldValue(objDjy, "bind", {0})
    local djyBind = GetTableFieldValue(objDjy, "bind", {1})
    local clUnbind = GetTableFieldValue(objCl, "bind", {0})
    local clBind = GetTableFieldValue(objCl, "bind", {1})
    if 0 == m_param.mode then
      if #djyUnbind > 0 and #clUnbind > 0 then
        djyPos = djyUnbind[1].index
        clPos = clUnbind[1].index
      elseif #djyBind > 0 and #clBind > 0 then
        djyPos = djyBind[1].index
        clPos = clBind[1].index
      end
    elseif 1 == m_param.mode then
      if #djyBind > 0 and #clBind > 0 then
        djyPos = djyBind[1].index
        clPos = clBind[1].index
      end
    elseif 2 == m_param.mode then
      if #djyUnbind > 0 and #clUnbind > 0 then
        djyPos = djyUnbind[1].index
        clPos = clUnbind[1].index
      end
    elseif 3 == m_param.mode then
      if #djyBind > 0 then
        djyPos = djyBind[1].index
      elseif #djyUnbind > 0 then
        djyPos = djyUnbind[1].index
      end
      if #clBind > 0 then
        clPos = clBind[1].index
      elseif #clUnbind > 0 then
        clPos = clUnbind[1].index
      end
    end
    if djyPos >= 0 and clPos >= 0 then
      GetLuaValue(fmt([[
                Clear_XSCRIPT();
                    Set_XSCRIPT_Function_Name("DianJin")
                    Set_XSCRIPT_ScriptID(892944)
                    Set_XSCRIPT_Parameter(0, 135); 
                    Set_XSCRIPT_Parameter(1, %d);  		
                    Set_XSCRIPT_Parameter(2, %d); 			
                    Set_XSCRIPT_Parameter(3, 1); 	
                    Set_XSCRIPT_ParamCount(4)
                Send_XSCRIPT();
            ]], clPos, djyPos))
      Sleep(100)
    end
  end
end

_SMain()
ScriptOnStop(m_script_name)
m_param = nil
