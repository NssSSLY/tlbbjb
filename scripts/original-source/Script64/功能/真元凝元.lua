-- 反编译自 dfz64.dll 内嵌字节码 0034e5e3（unluac 2025-12-23；仅供分析）
local m_script_name = "真元凝元"
ScriptOnStart(m_script_name, false, false)
g_config.zycj = {}
g_config.zycj.baise = ReadConfigBool("ZH", "xzk112")
g_config.zycj.lvse = ReadConfigBool("ZH", "xzk113")
g_config.zycj.lanse = ReadConfigBool("ZH", "xzk116")
g_config.zycj.zise = ReadConfigBool("ZH", "xzk117")
g_config.zycj.allname = ReadConfigText("ZH", "bjk179")

function _SMain(...)
  GoToScene(349, 229, 1)
  while true do
    local tObj = Enum2XByName("张士心", {
      1,
      0,
      0,
      0
    }, nil, nil, 0)
    if #tObj > 0 and tObj[1].dst <= 3 then
      local tmp = tObj[1]
      local strText = fmt([[
                local nChip = Pneuma:GetPneumaChip()
                if nChip >= 20 then
                    local nSpace = Pneuma:GetSmeltBag_SpaceCount()
                    if nSpace > 0 then
                        Clear_XSCRIPT()
                            Set_XSCRIPT_Function_Name("ApplyNiangLian")
                            Set_XSCRIPT_ScriptID(889902)
                            Set_XSCRIPT_Parameter(0, %d)
                            Set_XSCRIPT_ParamCount(1)
                        Send_XSCRIPT()
                        return 1
                    else 
                        return 2
                    end
                else
                    return 0
                end
                return -1
            ]], tmp.id)
      local nState = GetLuaValue(strText, "n")
      if 2 == nState then
        if ZYCJ_Action(72) == false then
          Sleep(1000)
          if GetLuaValue("return Pneuma:GetSmeltBag_SpaceCount()", "n") <= 0 then
            PushColorMsg(m_script_name .. ":已满且没有可淬解的")
            break
          end
        end
      elseif 0 == nState then
        PushColorMsg(m_script_name .. ":您已没有碎片")
        ZYCJ_Action(72)
        break
      end
    else
      GoToScene(349, 229, 1)
    end
    if false == CheckMibao() then
      PushColorMsg(m_script_name .. ":未解锁密保")
      break
    end
    Sleep(20)
    DebugStr(m_script_name)
  end
end

_SMain()
ScriptOnStop(m_script_name)
