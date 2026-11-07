-- 反编译自 dfz64.dll 内嵌字节码 0047029f（unluac 2025-12-23；仅供分析）
local m_script_name = "购买元丹坊"
ScriptOnStart(m_script_name, false, false, false)
g_config.gmydf = {}
g_config.gmydf.lyjw = ReadConfigText("ZH", "bjk58")
g_config.gmydf.lysw = ReadConfigText("ZH", "bjk90")
g_config.gmydf.zyyd = ReadConfigText("ZH", "bjk103")
g_config.gmydf.htyd = ReadConfigText("ZH", "bjk152")
g_config.gmydf.zsyd = ReadConfigText("ZH", "bjk153")
local m_param = {}
m_param.buy_lyjw = SplitString(g_config.gmydf.lyjw, " ", true)
m_param.buy_lysw = SplitString(g_config.gmydf.lysw, " ", true)
m_param.buy_zyyd = SplitString(g_config.gmydf.zyyd, " ", true)
m_param.buy_htyd = SplitString(g_config.gmydf.htyd, " ", true)
m_param.buy_zsyd = SplitString(g_config.gmydf.zsyd, " ", true)
local m_data = {}
m_data.npcID = -1

function _SMain(...)
  local nTickOut = -1
  CloseAllWindow()
  LoadScript("fn元丹坊")
  while true do
    if -1 ~= m_data.npcID and IsWindowVisible("PetNeidan_Shop") then
      if #m_param.buy_lyjw > 0 then
        local nRetType = YDF_BuyAction(m_param.buy_lyjw[1], 5)
        if 0 == nRetType then
          table.remove(m_param.buy_lyjw, 1)
        end
      elseif #m_param.buy_lysw > 0 then
        local nRetType = YDF_BuyAction(m_param.buy_lysw[1], 1)
        if 0 == nRetType then
          table.remove(m_param.buy_lysw, 1)
        end
      elseif #m_param.buy_zyyd > 0 then
        local nRetType = YDF_BuyAction(m_param.buy_zyyd[1], 2)
        if 0 == nRetType then
          table.remove(m_param.buy_zyyd, 1)
        end
      elseif #m_param.buy_htyd > 0 then
        local nRetType = YDF_BuyAction(m_param.buy_htyd[1], 3)
        if 0 == nRetType then
          table.remove(m_param.buy_htyd, 1)
        end
      else
        if not (#m_param.buy_zsyd > 0) then
          break
        end
        do
          local nRetType = YDF_BuyAction(m_param.buy_zsyd[1], 4)
          if 0 == nRetType then
            table.remove(m_param.buy_zsyd, 1)
          end
        end
        goto lbl_138
        break
      end
    else
      GoToSceneNPC("云丹丹", 178, 231, 1)
      local tObj = Enum2XByName("云丹丹", {
        1,
        0,
        0,
        0
      }, nil, nil, 0)
      if #tObj > 0 then
        m_data.npcID = tObj[1].id
        Sleep(500)
        DialogOptionClicked("元丹坊", 1, 1000)
      end
      Sleep(500)
    end
    ::lbl_138::
    if -1 == nTickOut then
      nTickOut = GetTickCount()
    end
    if GetTickCount() - nTickOut > 180000 then
      PushColorMsg(m_script_name .. ":超时")
    end
    Sleep(100)
    DebugStr(m_script_name)
  end
  CloseAllWindow()
end

_SMain()
ScriptOnStop(m_script_name)
