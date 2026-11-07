-- 反编译自 dfz64.dll 内嵌字节码 00450a02（unluac 2025-12-23；仅供分析）
local m_script_name = "情寄虞兮"
ScriptOnStart(m_script_name, true, true)

function _SMain(...)
  GoToSceneNPC("许望虞", 158, 100, 1075)
  Sleep(1000)
  if Team:IsCountReady(2) and IsTeamSteady() then
    Sleep(3000)
    QuestFrameOptionClicked_Item("#{QRYJH_221104_13}", 1, 1000)
    Sleep(1000)
  end
  while true do
    Dismount()
    local tymrh = Enum2XByName("盛开的虞美人花", {
      1,
      1,
      0,
      0
    }, nil, 1, 0)
    if #tymrh > 0 then
      local tmp = tymrh[1]
      TalkNpc(tmp.name)
      Sleep(1000)
      QuestFrameOptionClicked_Item("#{QRYJH_221104_135}", 1, 1000)
      Sleep(1000)
      break
    end
    local tObj = Enum2XByName("的花朵", {
      1,
      1,
      0,
      0
    }, nil, 1, 5)
    if #tObj > 0 then
      local tmp = tObj[1]
      TalkNpc(tmp.name)
      Sleep(1000)
      QuestFrameOptionClicked_Item("#{QRYJH_221104_21}", 1, 1000)
      Sleep(1000)
      Target:Select(tmp.id, 1000)
      GetLuaValue("setmetatable(_G, {__index = MainMenuBar_Env});MainMenuBar_Clicked(51);")
      TalkNpc(tmp.name)
      Sleep(1000)
      QuestFrameOptionClicked_Item("#{QRYJH_221104_135}", 1, 1000)
    elseif Player:IsLeader() then
      if Bag:GetItemCount("痴情种") > 0 then
        Dismount()
        Sleep(1000)
        Bag:UseItemByName_click("痴情种", 4000)
        Sleep(1000)
        Player:TeamFollow(true, 300)
        local strText = GetNPCEventList_Item(0)
        PushColorMsg(strText)
        if string.find(strText, "#{QRYJH_221104_130}", nil, true) then
          MoveTo(137, 40)
        elseif string.find(strText, "#{QRYJH_221104_131}", nil, true) then
          MoveTo(121, 116)
        elseif string.find(strText, "#{QRYJH_221104_132}", nil, true) then
          MoveTo(107, 165)
        elseif string.find(strText, "#{QRYJH_221104_133}", nil, true) then
          MoveTo(236, 125)
        elseif string.find(strText, "#{QRYJH_221104_134}", nil, true) then
          MoveTo(108, 218)
        end
        Dismount()
        Sleep(1000)
        Player:TeamFollow(false, 1000)
      end
    else
      Sleep(3000)
      PushColorMsg("队员等待队长操作")
    end
  end
end

PushColorMsg(GetSceneID())
_SMain()
ScriptOnStop(m_script_name, true)
