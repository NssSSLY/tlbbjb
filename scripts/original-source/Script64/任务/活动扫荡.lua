-- 反编译自 dfz64.dll 内嵌字节码 00297045（unluac 2025-12-23；仅供分析）
local m_script_name = "活动扫荡"
ScriptOnStart(m_script_name, false, false)

local function EnumSecKillTable_HuoDong(aIdx)
  local szTemp = fmt([[
            setmetatable(_G, { __index = SweepAll_Env });
            local idx = %d
		    local Id, IconName,FubenName,IsOpenKaji,needLevel,nSeckillNum1,nSeckillNum2,nSeckillNum3,xinfalevel,SecKillNeedNum,BossNum,_,_,_,_,ScriptID,ActionID,ActionID_Kaji = EnumSecKillTable_HuoDong(idx)

            return Id, IconName,FubenName,IsOpenKaji,needLevel,nSeckillNum1,nSeckillNum2,nSeckillNum3,xinfalevel,SecKillNeedNum,BossNum,_,_,_,_,ScriptID,ActionID,ActionID_Kaji
        ]], aIdx)
  local Id, IconName, FubenName, IsOpenKaji, needLevel, nSeckillNum1, nSeckillNum2, nSeckillNum3, xinfalevel, SecKillNeedNum, BossNum, _, _, _, _, ScriptID, ActionID, ActionID_Kaji = GetLuaValue(szTemp, "snnnnnnnnnnnnnnnnn")
  return Id, IconName, FubenName, IsOpenKaji, needLevel, nSeckillNum1, nSeckillNum2, nSeckillNum3, xinfalevel, SecKillNeedNum, BossNum, _, _, _, _, ScriptID, ActionID, ActionID_Kaji
end

function SaoDangHuoDong_xm()
  local SecKillFubenCount_HuoDong = GetLuaValue("return Lua_GetSecKillFuBenCount_HuoDong()", "n")
  for i = 0, SecKillFubenCount_HuoDong - 1 do
    local Id, IconName, FubenName, IsOpenKaji, needLevel, nSeckillNum1, nSeckillNum2, nSeckillNum3, xinfalevel, SecKillNeedNum, BossNum, _, _, _, _, ScriptID, ActionID, ActionID_Kaji = EnumSecKillTable_HuoDong(i)
    if 1 == Id or 2 == Id then
      if nSeckillNum1 < SecKillNeedNum then
        goto lbl_67
      end
    elseif 3 == Id or 4 == Id then
      if nSeckillNum2 < SecKillNeedNum then
        goto lbl_67
      end
    elseif (5 == Id or 6 == Id) and nSeckillNum3 < SecKillNeedNum then
      goto lbl_67
    end
    local Number = 0
    local Micount = 0
    local Micount, Number = GetLuaValue(fmt("return LuaGetSeckillCampaignTableNew_HuoDong(%d)", ActionID_Kaji), "nn")
    PushColorMsg(Micount)
    local lefttimes = Number - Micount
    if 0 == lefttimes then
    elseif 0 == Number then
    else
      PushDebugMessage("扫荡活动：" .. FubenName)
      GetLuaValue(fmt([[
        		Clear_XSCRIPT();
                    Set_XSCRIPT_Function_Name("OnFuBenSecKill");
                    Set_XSCRIPT_ScriptID(100003);
                    Set_XSCRIPT_Parameter(0,%d);
                    Set_XSCRIPT_ParamCount(1);
                Send_XSCRIPT();
            ]], Id))
    end
    ::lbl_67::
  end
end

function SDHD_OnStart(aParam)
  if not IsWindowVisible("SweepAll") then
    GetLuaValue("setmetatable(_G, {__index = PlayerQuicklyEnter_Env});PlayerQuicklyEnter_OpenSecKillBox()")
    Sleep(1000)
    GetLuaValue("setmetatable(_G, {__index = SweepAll_Env});SweepAll_Tab_2_OnClick();")
    Sleep(1000)
  end
  for i = 1, 20 do
    SaoDangHuoDong_xm()
  end
  local tObj = Bag:EnumDaoJuItem()
  local tFind = Bag:FindItem_vague("宝箱", 2, tObj)
  tFind = Bag:FindItem_vague("宝箱", 2, tObj)
  for i = 1, #tFind do
    local tmp = tFind[i]
    PushColorMsg(tmp.name)
    Bag:ItemBtnClicked(tmp.index)
    Sleep(300)
    GetLuaValue("setmetatable(_G, {__index = Item_MultiUse_Env});Item_MultiUse_BuyMulti_Clicked();")
  end
  ClearBag()
  Bag_SellItem()
  MainBankSaveItem()
  Bag_SellItem()
  MainBankSaveItem()
end

SDHD_OnStart(m_param)
ScriptOnStop(m_script_name)
