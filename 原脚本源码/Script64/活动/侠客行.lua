-- 反编译自 dfz64.dll 内嵌字节码 0043595d（unluac 2025-12-23；仅供分析）
local m_script_name = "侠客行"
ScriptOnStart(m_script_name, true, true)

function getstep(...)
  if -1 ~= GetPlayerMission_Item("#{XKXYD_250116_09}") then
    return 1
  elseif -1 ~= GetPlayerMission_Item("#{XKXYD_250116_41}") then
    return 2
  elseif -1 ~= GetPlayerMission_Item("#{XKXYD_250116_169}") then
    return 3
  elseif -1 ~= GetPlayerMission_Item("#{XKXYD_250116_98}") then
    return 4
  elseif -1 ~= GetPlayerMission_Item("#{XKXYD_250116_135}") then
    return 5
  else
    GoToSceneNPC("木影", 138, 24, 1016)
    Sleep(1000)
    local strDesc = GetNPCEventList_Item(5)
    PushColorMsg(strDesc)
    if string.find(strDesc, "#{XKXYD_250116_09}", nil, true) then
      return 1
    elseif string.find(strDesc, "#{XKXYD_250116_41}", nil, true) then
      return 2
    elseif string.find(strDesc, "#{XKXYD_250116_169}", nil, true) then
      return 3
    elseif string.find(strDesc, "#{XKXYD_250116_98}", nil, true) then
      return 4
    elseif string.find(strDesc, "#{XKXYD_250116_135}", nil, true) then
      return 5
    else
      return 0
    end
  end
end

function _SMain(...)
  while true do
    local step = getstep()
    PushColorMsg(step)
    if 1 == step then
      local nIndex = GetPlayerMission_Item("#{XKXYD_250116_09}")
      if -1 == nIndex then
        GoToSceneNPC("木影", 138, 24, 1016)
        Sleep(1000)
        DialogOptionClicked("#{XKXYD_250116_09}", 1, 700)
        Sleep(1000)
        QuestFrameAcceptClicked(2000)
      else
        local nParam = GetMissionComplete(nIndex)
        if 0 == nParam then
          GoToSceneNPC("木影", 138, 24, 1016)
          Sleep(1000)
          DialogOptionClicked("#{XKXYD_250116_09}", 1, 700)
          Sleep(1000)
          DialogOptionClicked("#{XKXYD_250116_13}", 1, 700)
          Sleep(1000)
          DialogOptionClicked("#{XKXYD_250116_28}", 1, 700)
          Sleep(1000)
          DialogOptionClicked("#{XKXYD_250116_30}", 1, 700)
          Sleep(1000)
          DialogOptionClicked("#{XKXYD_250116_32}", 1, 700)
        else
          GoToSceneNPC("木影", 138, 24, 1016)
          Sleep(1000)
          DialogOptionClicked("#{XKXYD_250116_09}", 1, 700)
          Sleep(200)
          QuestFrameMissionComplete(nil, 700)
        end
      end
    elseif 2 == step then
      local nIndex = GetPlayerMission_Item("#{XKXYD_250116_41}")
      if -1 == nIndex then
        GoToSceneNPC("木影", 138, 24, 1016)
        Sleep(1000)
        DialogOptionClicked("#{XKXYD_250116_41}", 1, 700)
        Sleep(1000)
        QuestFrameAcceptClicked(2000)
      else
        local nParam = GetMissionComplete(nIndex)
        if 0 == nParam then
          Dismount()
          Bag:UseItemByName_click("召引竹哨", 1000, Bag:EnumDaoJuItem())
          Sleep(200)
          local szTalkTitle = GetNPCEventList_Item(0)
          local xPos, yPos, sceneID = szTalkTitle:match("%*[%c]*(%d+)%*[%c]*(%d+)%*[%c]*(%d+)")
          xPos = tonumber(xPos)
          yPos = tonumber(yPos)
          sceneID = tonumber(sceneID)
          PushDebugMessage("召引竹哨:%d,%d,%d", xPos, yPos, sceneID)
          MoveTo(xPos, yPos, sceneID)
          Dismount()
          Sleep(200)
          Bag:UseItemByName_click("召引竹哨", 1000, Bag:EnumDaoJuItem())
          Sleep(300)
          local tObj = Enum2XByName("江湖宵小", {
            0,
            1,
            0,
            0
          }, nil, nil, 4)
          if #tObj > 0 then
            for i = 1, #tObj do
              local tmp = tObj[i]
              FubenAttack(tmp.id)
            end
          end
        else
          GoToSceneNPC("木影", 138, 24, 1016)
          Sleep(1000)
          DialogOptionClicked("#{XKXYD_250116_41}", 1, 700)
          Sleep(200)
          QuestFrameMissionComplete(nil, 700)
        end
      end
    elseif 3 == step then
      local nIndex = GetPlayerMission_Item("#{XKXYD_250116_169}")
      if -1 == nIndex then
        GoToSceneNPC("木影", 138, 24, 1016)
        Sleep(1000)
        DialogOptionClicked("#{XKXYD_250116_169}", 1, 700)
        Sleep(1000)
        QuestFrameAcceptClicked(2000)
      else
        local nParam = GetMissionComplete(nIndex)
        if 0 == nParam then
          PushColorMsg("不知道该干嘛")
        else
          GoToSceneNPC("木影", 138, 24, 1016)
          Sleep(1000)
          DialogOptionClicked("#{XKXYD_250116_169}", 1, 700)
          Sleep(200)
          QuestFrameMissionComplete(nil, 700)
        end
      end
    elseif 4 == step then
      local nIndex = GetPlayerMission_Item("#{XKXYD_250116_98}")
      if -1 == nIndex then
        GoToSceneNPC("木影", 138, 24, 1016)
        Sleep(1000)
        DialogOptionClicked("#{XKXYD_250116_98}", 1, 700)
        Sleep(1000)
        QuestFrameAcceptClicked(2000)
      else
        local nParam = GetMissionComplete(nIndex)
        if 0 == nParam then
          if GetSceneID() == 1017 then
            RunTo(126, 53)
            local tObj = Enum2XByName("莽牯毒蛤·影", {
              0,
              1,
              0,
              0
            }, nil, 1, 0)
            if #tObj > 0 then
              for i = 1, #tObj do
                local tmp = tObj[i]
                FubenAttack(tmp.id)
              end
            end
          else
            GoToSceneNPC("木影", 138, 24, 1016)
            Sleep(1000)
            DialogOptionClicked("#{XKXYD_250116_98}", 1, 700)
            Sleep(1000)
            DialogOptionClicked("#{XKXYD_250116_168}", 1, 700)
          end
        elseif GetSceneID() == 1017 then
          GoToSceneNPC("木离", 127, 40, 1017)
          Sleep(1000)
          DialogOptionClicked("#{XKXYD_250116_123}", 1, 700)
        else
          GoToSceneNPC("木影", 138, 24, 1016)
          Sleep(1000)
          DialogOptionClicked("#{XKXYD_250116_98}", 1, 700)
          Sleep(200)
          QuestFrameMissionComplete(nil, 700)
        end
      end
    elseif 5 == step then
      local nIndex = GetPlayerMission_Item("#{XKXYD_250116_135}")
      if -1 == nIndex then
        GoToSceneNPC("木影", 138, 24, 1016)
        Sleep(1000)
        DialogOptionClicked("#{XKXYD_250116_135}", 1, 700)
        Sleep(1000)
        QuestFrameAcceptClicked(2000)
      else
        local nParam = GetMissionComplete(nIndex)
        if 0 == nParam then
          GoToSceneNPC("龙辛", 127, 24)
          Sleep(1000)
          DialogOptionClicked("#{XKSD_250110_03}", 1, 700)
          Sleep(1000)
          GetLuaValue("setmetatable(_G, {__index = Xiake_Shop_Env});Xiake_Shop_Buy(2)")
          Sleep(1000)
          GetLuaValue("setmetatable(_G, {__index = Xiake_Shop_Mbuy_Env});Xiake_Shop_MBuy_OK_Clicked();")
          Sleep(1000)
        else
          GoToSceneNPC("龙辛", 127, 24)
          Sleep(1000)
          DialogOptionClicked("#{XKXYD_250116_135}", 1, 700)
          Sleep(200)
          QuestFrameMissionComplete(nil, 700)
        end
      end
    elseif 0 == step then
      PushColorMsg("侠客行引导任务已完成")
      break
    end
  end
end

PushColorMsg(GetSceneID())
_SMain()
ScriptOnStop(m_script_name, true)
