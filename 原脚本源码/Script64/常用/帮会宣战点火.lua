-- 反编译自 dfz64.dll 内嵌字节码 0037e50f（unluac 2025-12-23；仅供分析）
local m_banghui_ids = ReadConfigText("ZH", "bjk149")
local m_xuanzhan = {}

local function BH_xuanzhan()
  GetLuaValue("City:AskEnemyList(0);City:AskEnemyList(1);")
  Sleep(1000)
  for i = 1, #m_xuanzhan do
    local strText = fmt([[
                local tid = %d
                local bHave = 0
                local nNum = City:GetEnemyNum(0);
                for i = 0, nNum - 1 do
                    local nGulidid = City:EnumCityEnemy(0, i, "guildid");
                    local szGuildName = City:EnumCityEnemy(0, i, "name");
                    local szLeftTime = City:EnumCityEnemy(0, i, "lefttime");
                    if nGulidid == tid then 
                        bHave = 1 
                        break 
                    end
                end

                if bHave == 0 then
                    nNum = City:GetEnemyNum(1);
                    for j = 0, nNum - 1 do
                        local nGulidid = City:EnumCityEnemy(1, j, "guildid");
                        local szGuildName = City:EnumCityEnemy(1, j, "name");
                        local szLeftTime = City:EnumCityEnemy(1, j, "lefttime");
                        if nGulidid == tid then 
                            bHave = 1 
                            break 
                        end
                    end
                end
                return bHave
            ]], m_xuanzhan[i])
    if GetLuaValue(strText, "b") == false then
      PushDebugMessage("自动宣战帮会ID：" .. m_xuanzhan[i])
      GetLuaValue(fmt("City:OpenAddEnemyDlg(\"BenFu\",%d);", m_xuanzhan[i]))
      Sleep(3000)
      break
    end
  end
end

function _SMain(...)
  local arr = SplitString(m_banghui_ids, " ", true)
  for i = 1, #arr do
    local n = tonumber(arr[i])
    if n and n >= 0 then
      table.insert(m_xuanzhan, n)
    end
  end
  if #m_xuanzhan > 0 then
    while true do
      BH_xuanzhan()
      Sleep(3000)
      DebugStr("帮会宣战点火")
    end
  else
    PushDebugMessage("未设置宣战帮会ID")
  end
end

_SMain()
