-- 反编译自 dfz64.dll 内嵌字节码 00452b92（unluac 2025-12-23；仅供分析）
local m_script_name = "问画朔源"
ScriptOnStart(m_script_name, true, true)

function _SMain(...)
  GetLuaValue("setmetatable(_G, {__index = PlayerQuicklyEnter_Env});PlayerQuicklyEnter_Clicked(91);")
  Sleep(1000)
  GetLuaValue("setmetatable(_G, {__index = QiXi_StoryLetter_Env});QiXi_StoryLetter_Stage1_OpenBtn_OnClick();")
  Sleep(2000)
  GetLuaValue("setmetatable(_G, {__index = QiXi_StoryLetter_Env});QiXi_StoryLetter_OpenBtn_1_OnClick();")
  Sleep(5000)
  GetLuaValue("setmetatable(_G, {__index = QiXi_StoryLetter_Env});QiXi_StoryLetter_OpenBtn_2_OnClick();")
  Sleep(5000)
  GetLuaValue("setmetatable(_G, {__index = QiXi_StoryLetter_Env});QiXi_StoryLetter_OpenBtn_3_OnClick();")
  Sleep(5000)
  GetLuaValue("setmetatable(_G, {__index = QiXi_StoryLetter_Env});QiXi_StoryLetter_JieMiBtn_OnClick();")
  Sleep(2000)
  GetLuaValue("setmetatable(_G, {__index = QiXi_StoryLetter_Env});QiXi_StoryLetter_GoBtn_OnClick();")
  Sleep(1000)
  GetLuaValue("setmetatable(_G, {__index = QiXi_StoryLetter_Env});QiXi_StoryLetter_Close();")
  Sleep(1000)
  GoToSceneNPC("卢氏女", 254, 252, LUOYANG_ID)
  Sleep(1000)
  QuestFrameOptionClicked_Item("#{XYYJ_260529_23}", 1, 1000)
  Sleep(1000)
  QuestFrameMissionComplete(nil, 700)
  Sleep(1000)
  QuestFrameAcceptClicked(2000)
  Sleep(1000)
  GoToSceneNPC("卢氏女", 254, 252, LUOYANG_ID)
  Sleep(1000)
  QuestFrameOptionClicked_Item("#{GXCJ_260604_03}", 1, 1000)
  Sleep(1000)
  while true do
    local nIndex = GetPlayerMission_Item("#{XYYJ_260529_49}")
    PushColorMsg(nIndex)
    if -1 == nIndex then
      GoToSceneNPC("卢氏女", 254, 252, LUOYANG_ID)
      GetLuaValue("setmetatable(_G, {__index = QiXi_Guide_2026_Env});QiXi_Guide_2026_HolidayGift_Clicked();")
      Sleep(1000)
      GetLuaValue("setmetatable(_G, {__index = QiXi_HolidayGift_Env});QiXi_HolidayGift_GetClick();")
      break
    else
      local nParam = GetMissionComplete(nIndex)
      PushColorMsg(nParam)
      if 0 == nParam then
        if GetSceneID() == 1075 then
          Bag:UseItemByName_click("溯缘镜的碎片", 4000)
          Sleep(3000)
          MoveTo(144, 117)
          repeat
            Sleep(500)
            local tObj = Enum2XByName("遗失的碎镜片", {
              1,
              1,
              0,
              0
            }, {0, -1}, nil, 0)
          until #tObj > 0
          local tObj = Enum2XByName("遗失的碎镜片", {
            1,
            1,
            0,
            0
          }, {0, -1}, nil, 0)
          for i = 1, #tObj do
            if "遗失的碎镜片" == tObj[i].name then
              MoveTo(tObj[i].x, tObj[i].y)
              Dismount()
              Skill.CUseSkillByID(6060, tObj[i].id, -1, -1)
              Sleep(7000)
            end
          end
          MoveTo(99, 196)
          repeat
            Sleep(500)
            local tObj = Enum2XByName("遗失的碎镜片", {
              1,
              1,
              0,
              0
            }, {0, -1}, nil, 0)
          until #tObj > 0
          local tObj = Enum2XByName("遗失的碎镜片", {
            1,
            1,
            0,
            0
          }, {0, -1}, nil, 0)
          for i = 1, #tObj do
            if "遗失的碎镜片" == tObj[i].name then
              MoveTo(tObj[i].x, tObj[i].y)
              Dismount()
              Skill.CUseSkillByID(6060, tObj[i].id, -1, -1)
              Sleep(7000)
            end
          end
          MoveTo(182, 39)
          repeat
            Sleep(500)
            local tObj = Enum2XByName("遗失的碎镜片", {
              1,
              1,
              0,
              0
            }, {0, -1}, nil, 0)
          until #tObj > 0
          local tObj = Enum2XByName("遗失的碎镜片", {
            1,
            1,
            0,
            0
          }, {0, -1}, nil, 0)
          for i = 1, #tObj do
            if "遗失的碎镜片" == tObj[i].name then
              MoveTo(tObj[i].x, tObj[i].y)
              Dismount()
              Skill.CUseSkillByID(6060, tObj[i].id, -1, -1)
              Sleep(7000)
            end
          end
        end
      elseif GetSceneID() == 1075 then
        GoToSceneNPC("卢姑娘", 213, 119, 1075)
        Sleep(1000)
        QuestFrameOptionClicked_Item("#{XYYJ_260529_49}", 1, 1000)
        Sleep(1000)
        QuestFrameMissionComplete(nil, 700)
        Sleep(1000)
        GetLuaValue("setmetatable(_G, {__index = QiXi_Guide_2026_Env});QiXi_Guide_2026_HolidayGift_Clicked();")
        Sleep(1000)
        GetLuaValue("setmetatable(_G, {__index = QiXi_HolidayGift_Env});QiXi_HolidayGift_GetClick();")
        break
      end
    end
  end
end

PushColorMsg(GetSceneID())
_SMain()
ScriptOnStop(m_script_name, true)
