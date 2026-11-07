-- 反编译自 dfz64.dll 内嵌字节码 0047c440（unluac 2025-12-23；仅供分析）
local m_script_name = "鬼市千金阁买物"
ScriptOnStart(m_script_name, true, false)
local m_FlagAwardItem = {
  {
    name = "张世平",
    sceneID = 2,
    x = 68,
    y = 178,
    pic = "set:GuiShiEnter image:MenKeName1"
  },
  {
    name = "柳金蟾",
    sceneID = 1,
    x = 222,
    y = 235,
    pic = "set:GuiShiEnter image:MenKeName2"
  },
  {
    name = "赵钱孙",
    sceneID = LUOYANG_ID,
    x = 183,
    y = 232,
    pic = "set:GuiShiEnter image:MenKeName3"
  }
}

function _SMain()
  local nTickOut = -1
  ClearBag()
  CloseAllWindow()
  local buyItemName = HandleText(GetConfigText("千金阁购物", "物品名称"))
  local buyTable = Text2Table(buyItemName, " ", "name")
  for i = 1, #buyTable do
    buyTable[i].canbuy = true
  end
  if #buyTable > 0 then
    local npc = m_FlagAwardItem[3]
    ::lbl_29::
    if FindTableFieldValue(buyTable, "canbuy", true) == false then
      PushColorMsg(m_script_name .. ":已无可购买物品")
    else
      if IsWindowVisible("GuiShi_Shop") then
        for i = 1, #buyTable do
          local buyCount = 1
          if buyTable[i].name == "金蚕丝" then
            buyCount = 10
          end
          local state = GuiShi_BuyItem(buyTable[i].name, buyCount)
          if 3 == state then
            buyTable[i].canbuy = false
          end
          if 0 == state then
            buyTable[i].canbuy = false
          end
          if 4 == state then
            if buyCount > 1 then
              buyCount = 1
              state = GuiShi_BuyItem(buyTable[i].name, buyCount)
            end
            if 4 == state and 1 == buyCount then
              buyTable[i].canbuy = false
            end
          end
          Sleep(200)
        end
      else
        GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
        QuestFrameOptionClicked_Item("#{GSHB_190801_47}", 1, 700)
      end
      if -1 == nTickOut then
        nTickOut = GetTickCount()
      end
      if -1 ~= nTickOut and GetTickCount() - nTickOut > 180000 then
        PushColorMsg(m_script_name .. "：执行超时")
      else
        Sleep(500)
        DebugStr(m_script_name)
        goto lbl_29
      end
    end
  else
    PushColorMsg(m_script_name .. ":没有正确的物品名称,多个物品空格分开")
  end
  CloseAllWindow()
end

_SMain()
ScriptOnStop(m_script_name, false)
