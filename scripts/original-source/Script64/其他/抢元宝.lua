-- 反编译自 dfz64.dll 内嵌字节码 002af50f（unluac 2025-12-23；仅供分析）
local m_nTick = ReadConfigInt("ZH", "bjk62")
local m_fProp = ReadConfigInt("ZH", "bjk61")

local function YuanBao_ChangeTabIndex(npcID, tabIndex)
  GetLuaValue(fmt([[
	   
		    Clear_XSCRIPT();
				Set_XSCRIPT_Function_Name("OpenShop");
				Set_XSCRIPT_ScriptID(800116);
				Set_XSCRIPT_Parameter(0,%d);
				Set_XSCRIPT_Parameter(1,%d);
				Set_XSCRIPT_ParamCount(2);
		    Send_XSCRIPT();			
		]], npcID, tabIndex))
end

function YuanBao_TraverseShop(aProp)
  return GetLuaValue(fmt("\t\t\tlocal Prop = %f\n\t\t\tlocal money = Player:GetData(\"MONEY\")\n\t\t\tif money < 500000 * Prop then  return -2 end\t\t\t\n            setmetatable(_G, {__index = CommisionStall_Env});\n\t\t    for i = 1 , 20 do\n\t\t\t\tlocal theAction = CommisionShop:EnumAction(i-1);\t\t\t\t\n\t\t\t\tif theAction and theAction:GetID() ~= 0 then\n\t\t\t\t\tlocal price = CommisionShop:EnumItem(0,i-1,\"price\");\n\t\t\t\t\tlocal name = CommisionShop:EnumItem(0,i-1,\"name\");\n                    local szPrice = string.gsub(name, \"元宝票\", \"\")\n                    if szPrice ~= nil and szPrice ~= \"\" then \n                        local nYBPrice = tonumber(szPrice)                        \n                        if nYBPrice > 0 then \n                            local fProp = tonumber(price)/(10000 * nYBPrice) -- 寄售比例\n                            if tonumber(price) < money and fProp <= Prop then \n                                return i - 1\n                            end \n                        end\n                    end                   \t\n\t\t\t\tend\n            end\t\n\t\t\treturn -1\t\t\t\n        ", aProp), "n")
end

function YuanBao_Buy(npcID, tabIndex, nIndex)
  GetLuaValue(fmt("\t\t\tlocal Sailer = CommisionShop:EnumItem(0,%d,\"serial\");--获取相应格子的物品ID,第一个参数0购买,1寄售\n            PushDebugMessage(Sailer)\n\t\t\tClear_XSCRIPT();\n\t\t\t\tSet_XSCRIPT_Function_Name(\"Buy\");--调用此也会自动打开寄售窗口,金钱不足,会返回金钱不足的提示\n\t\t\t\tSet_XSCRIPT_ScriptID(800116);\n\t\t\t\tSet_XSCRIPT_Parameter(0, %d);--NPCID\n\t\t\t\tSet_XSCRIPT_Parameter(1, %d); \n\t\t\t\tSet_XSCRIPT_Parameter(2, tonumber(Sailer));\n\t\t\t\tSet_XSCRIPT_ParamCount(3);\n\t\t\tSend_XSCRIPT();\t\t\t\t\n    ", nIndex, npcID, tabIndex))
end

function _SMain(...)
  if m_fProp <= 0 then
    PushDebugMessage("抢元宝：错误的比例！")
    return
  end
  PushColorMsg("抢元宝：当前比例 %.2f%% ，请携带适量的金币。", m_fProp)
  m_fProp = m_fProp / 100
  local idDing, idDong, idNPC = -1, -1, -1
  local npcIdx = -1
  local old_YuanBao = Player:GetDataInt("YUANBAO")
  local old_Money = Player:GetMoney(1)
  while true do
    if IsDestination(255, 321, LUOYANG_ID, 2) and -1 ~= idDing and -1 ~= idDong then
      if 0 == npcIdx then
        idNPC = idDing
      else
        idNPC = idDong
      end
      for tab = 0, 2 do
        YuanBao_ChangeTabIndex(idNPC, tab)
        Sleep(150 + m_nTick)
        local nIndex = YuanBao_TraverseShop(m_fProp)
        if -2 == nIndex then
          PushColorMsg("剩余金币已不足支付最小面额元宝,结束！")
          return
        elseif nIndex >= 0 then
          YuanBao_Buy(idNPC, tab, nIndex)
        end
        local YuanBao = Player:GetDataInt("YUANBAO")
        if YuanBao ~= old_YuanBao then
          local Money = Player:GetMoney(1)
          PushColorMsg("您花费 %.2f 金成功购买了 %d 元宝！", (old_Money - Money) / 10000, YuanBao - old_YuanBao)
          old_YuanBao = YuanBao
          old_Money = Money
        end
      end
      if 0 == npcIdx then
        npcIdx = 1
      else
        npcIdx = 0
      end
    else
      DebugStr("前往元宝寄售NPC处...")
      MoveTo(255, 321, LUOYANG_ID, 2)
      Sleep(2000)
      idDing, idDong, idNPC = -1, -1, -1
      local tObj = Enum2XByName("汀汀", {
        1,
        1,
        0,
        0
      }, nil, nil, 0)
      if #tObj > 0 then
        idDing = tObj[1].id
      end
      tObj = Enum2XByName("冬冬", {
        1,
        1,
        0,
        0
      }, nil, nil, 0)
      if #tObj > 0 then
        idDong = tObj[1].id
      end
    end
  end
end

_SMain()
