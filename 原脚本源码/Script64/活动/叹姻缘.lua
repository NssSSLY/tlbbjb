-- 反编译自 dfz64.dll 内嵌字节码 00451266（unluac 2025-12-23；仅供分析）
local m_script_name = "叹姻缘"
ScriptOnStart(m_script_name, true, true)

function hookjd()
  GetLuaValue("setmetatable(_G, {__index = PlayerQuicklyEnter_Env});PlayerQuicklyEnter_Clicked(90);")
  Sleep(1000)
  DeleteDebugMsg("#{QXYR_260601_181}")
  DeleteDebugMsg("#{QXYR_260601_176}")
  GetLuaValue("setmetatable(_G, {__index = Qixi_Yure_Env});Qixi_Yure_Goto();")
  Sleep(1000)
  if IsInDebugMsg("#{QXYR_260601_176}") then
    return 0
  end
  Sleep(1000)
  GetLuaValue("setmetatable(_G, {__index = Qixi_Yure_Env});Qixi_Yure_GetReward(1);")
  Sleep(1000)
  if IsInDebugMsg("#{QXYR_260601_181}") then
    return 1
  end
  GetLuaValue("setmetatable(_G, {__index = Qixi_Yure_Env});Qixi_Yure_GetReward(2);")
  Sleep(1000)
  if IsInDebugMsg("#{QXYR_260601_181}") then
    return 2
  end
  GetLuaValue("setmetatable(_G, {__index = Qixi_Yure_Env});Qixi_Yure_GetReward(3);")
  Sleep(1000)
  if IsInDebugMsg("#{QXYR_260601_181}") then
    return 3
  end
  GetLuaValue("setmetatable(_G, {__index = Qixi_Yure_Env});Qixi_Yure_GetReward(4);")
  Sleep(1000)
  if IsInDebugMsg("#{QXYR_260601_181}") then
    return 4
  end
  GetLuaValue("setmetatable(_G, {__index = Qixi_Yure_Env});Qixi_Yure_GetReward(5);")
  Sleep(1000)
  if IsInDebugMsg("#{QXYR_260601_181}") then
    return 5
  end
  return 0
end

function _SMain(...)
  while true do
    local stepindex = hookjd()
    PushColorMsg(stepindex)
    if 0 == stepindex then
      break
    end
    if 1 == stepindex then
      local nIndex = GetPlayerMission_Item("#{QXYR_260601_23}")
      if -1 == nIndex then
        GoToSceneNPC("白颖中", 229, 307, LUOYANG_ID)
        Sleep(1000)
        QuestFrameOptionClicked_Item("#{QXYR_260601_23}", 1, 1000)
        Sleep(1000)
        QuestFrameAcceptClicked(2000)
      else
        local nParam = GetMissionComplete(nIndex)
        if 0 == nParam then
          GoToSceneNPC("卢氏女", 225, 302, LUOYANG_ID)
          Sleep(1000)
          QuestFrameOptionClicked_Item("#{QXYR_260601_22}", 1, 1000)
          Sleep(1000)
          GoToSceneNPC("白颖中", 229, 307, LUOYANG_ID)
          Sleep(1000)
          QuestFrameOptionClicked_Item("#{QXYR_260601_31}", 1, 1000)
        else
          GoToSceneNPC("蔷薇", 234, 297, LUOYANG_ID)
          Sleep(1000)
          QuestFrameOptionClicked_Item("#{QXYR_260601_23}", 1, 1000)
          Sleep(1000)
          QuestFrameMissionComplete(nil, 700)
        end
      end
    else
      GetLuaValue("setmetatable(_G, {__index = Qixi_Yure_Env});Qixi_Yure_GetReward(1);")
    end
    if 2 == stepindex then
      local nIndex = GetPlayerMission_Item("#{QXYR_260601_24}")
      if -1 == nIndex then
        GoToSceneNPC("蔷薇", 234, 297, LUOYANG_ID)
        Sleep(1000)
        QuestFrameOptionClicked_Item("#{QXYR_260601_24}", 1, 1000)
        Sleep(1000)
        QuestFrameAcceptClicked(2000)
      else
        local nParam = GetMissionComplete(nIndex)
        if 0 == nParam then
          GoToSceneNPC("白萌生", 230, 308, LUOYANG_ID)
          Sleep(1000)
          Shop_BuyItem("茯苓膏", 1)
          Shop_BuyItem("行气散", 1)
          Shop_BuyItem("桑菊粥", 1)
          Sleep(1000)
          GoToSceneNPC("煎药炉", 233, 302, LUOYANG_ID)
          Sleep(1000)
          QuestFrameOptionClicked_Item("#{QXYR_260601_30}", 1, 1000)
          Sleep(60000)
        else
          GoToSceneNPC("卢氏女", 225, 302, LUOYANG_ID)
          Sleep(1000)
          QuestFrameOptionClicked_Item("#{QXYR_260601_24}", 1, 1000)
          Sleep(1000)
          QuestFrameMissionComplete(nil, 700)
        end
      end
    else
      GetLuaValue("setmetatable(_G, {__index = Qixi_Yure_Env});Qixi_Yure_GetReward(2);")
    end
    if 3 == stepindex then
      local nIndex = GetPlayerMission_Item("#{QXYR_260601_25}")
      if -1 == nIndex then
        GoToSceneNPC("卢氏女", 225, 302, LUOYANG_ID)
        Sleep(1000)
        QuestFrameOptionClicked_Item("#{QXYR_260601_25}", 1, 1000)
        Sleep(1000)
        QuestFrameAcceptClicked(2000)
      else
        local nParam = GetMissionComplete(nIndex)
        if 0 == nParam then
          GoToSceneNPC("吴此仁", 335, 279, LUOYANG_ID)
          Sleep(1000)
          QuestFrameOptionClicked_Item("#{QXYR_260601_32}", 1, 1000)
          Sleep(1000)
          GoToSceneNPC("卢氏女", 225, 302, LUOYANG_ID)
          Sleep(1000)
          Dismount()
          local tObj = Enum2XByClass("NPC")
          if #tObj > 0 then
            for i = 1, #tObj do
              if string.find(tObj[i].name, "卢氏女", nil, true) then
                Target:Select(tObj[i].id)
                Sleep(1000)
                Bag:UseItemByName_click("溯缘镜的碎片", 4000)
              end
            end
          end
        else
          GoToSceneNPC("卢氏女", 225, 302, LUOYANG_ID)
          Sleep(1000)
          QuestFrameOptionClicked_Item("#{QXYR_260601_25}", 1, 1000)
          Sleep(1000)
          QuestFrameMissionComplete(nil, 700)
        end
      end
    else
      GetLuaValue("setmetatable(_G, {__index = Qixi_Yure_Env});Qixi_Yure_GetReward(3);")
    end
    if 4 == stepindex then
      local nIndex = GetPlayerMission_Item("#{QXYR_260601_26}")
      if -1 == nIndex then
        GoToSceneNPC("卢氏女", 225, 302, LUOYANG_ID)
        Sleep(1000)
        QuestFrameOptionClicked_Item("#{QXYR_260601_26}", 1, 1000)
        Sleep(1000)
        QuestFrameAcceptClicked(2000)
      else
        local nParam = GetMissionComplete(nIndex)
        if 0 == nParam then
          GoToSceneNPC("吴此仁", 335, 279, LUOYANG_ID)
          Sleep(1000)
          QuestFrameOptionClicked_Item("#{QXYR_260601_33}", 1, 1000)
          Sleep(1000)
          GoToSceneNPC("邱碧特", 272, 242, LUOYANG_ID)
          Sleep(1000)
          QuestFrameOptionClicked_Item("#{QXYR_260601_34}", 1, 1000)
          Sleep(1000)
          GoToSceneNPC("花仙", 138, 180, LUOYANG_ID)
          Sleep(1000)
          QuestFrameOptionClicked_Item("#{QXYR_260601_34}", 1, 1000)
          Sleep(1000)
          QuestFrameOptionClicked_Item("#{QXYR_260601_143}", 1, 1000)
          Sleep(1000)
          QuestFrameOptionClicked_Item("#{QXYR_260601_150}", 1, 1000)
          Sleep(1000)
          QuestFrameOptionClicked_Item("#{QXYR_260601_144}", 1, 1000)
          Sleep(1000)
          QuestFrameOptionClicked_Item("#{QXYR_260601_150}", 1, 1000)
          Sleep(1000)
          QuestFrameOptionClicked_Item("#{QXYR_260601_146}", 1, 1000)
        else
          GoToSceneNPC("卢氏女", 225, 302, LUOYANG_ID)
          Sleep(1000)
          QuestFrameOptionClicked_Item("#{QXYR_260601_26}", 1, 1000)
          Sleep(1000)
          QuestFrameMissionComplete(nil, 700)
        end
      end
    else
      GetLuaValue("setmetatable(_G, {__index = Qixi_Yure_Env});Qixi_Yure_GetReward(4);")
    end
    if 5 == stepindex then
      local nIndex = GetPlayerMission_Item("#{QXYR_260601_27}")
      if -1 == nIndex then
        GoToSceneNPC("卢氏女", 225, 302, LUOYANG_ID)
        Sleep(1000)
        QuestFrameOptionClicked_Item("#{QXYR_260601_27}", 1, 1000)
        Sleep(1000)
        QuestFrameAcceptClicked(2000)
      else
        local nParam = GetMissionComplete(nIndex)
        if 0 == nParam then
          GoToSceneNPC("白颖中", 229, 307, LUOYANG_ID)
          Sleep(1000)
          Bag:UseItemByName_click("卢氏糕饼", 4000)
          GoToSceneNPC("蔷薇", 234, 297, LUOYANG_ID)
          Sleep(1000)
          Bag:UseItemByName_click("卢氏糕饼", 4000)
          GoToSceneNPC("吴此仁", 335, 279, LUOYANG_ID)
          Sleep(1000)
          Bag:UseItemByName_click("卢氏糕饼", 4000)
          GoToSceneNPC("邱碧特", 272, 242, LUOYANG_ID)
          Sleep(1000)
          Bag:UseItemByName_click("卢氏糕饼", 4000)
          GoToSceneNPC("花仙", 138, 180, LUOYANG_ID)
          Sleep(1000)
          Bag:UseItemByName_click("卢氏糕饼", 4000)
        else
          GoToSceneNPC("卢氏女", 225, 302, LUOYANG_ID)
          Sleep(1000)
          QuestFrameOptionClicked_Item("#{QXYR_260601_27}", 1, 1000)
          Sleep(1000)
          QuestFrameMissionComplete(nil, 700)
          Sleep(1000)
          CloseAllWindow()
          Sleep(1000)
          GetLuaValue("setmetatable(_G, {__index = PlayerQuicklyEnter_Env});PlayerQuicklyEnter_Clicked(90);")
          Sleep(1000)
          GetLuaValue("setmetatable(_G, {__index = Qixi_Yure_Env});Qixi_Yure_GetReward(5);")
          break
        end
      end
    end
  end
end

PushColorMsg(GetSceneID())
local strTemp = GetPlayerMissionAllName()
LogMsg(strTemp)
_SMain()
ScriptOnStop(m_script_name, true)
