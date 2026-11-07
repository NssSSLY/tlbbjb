-- 一千零一个愿望：由 dfz64.dll 字节码模块 日常/一千零一个愿望.lua 静态还原
-- 模块 SHA256 2703e1470802e7ea77689072d1f9d63442acfc11b795f8444ecbe50fec2424a4；调用、参数、等待和循环按反汇编逐条保持。下马后的坐骑状态等待简化为固定 1 秒；结束时把剩余愿灵泉挪回锦囊的步骤未接入。
local m_script_name = "一千零一个愿望"
ScriptOnStart(m_script_name)
local function CheckItem(aMissionName)
    local nNeed = 5
    local nIndex = GetPlayerMission_Item(aMissionName)
    if nIndex ~= -1 then nNeed = 5 - GetMissionVariable(nIndex, 1) end
    if Bag:GetItemCount("愿灵泉", 0, 0, Bag:EnumDaoJuItem()) < nNeed then
        if TempBank2Bag("愿灵泉", 0) == false then
            Bank_GetItem("愿灵泉", nNeed, nil, nil, true)
        end
        Sleep(500)
        return false
    end
    return true
end
function _SMain()
    local npc = { { name = "梁道士", x = 282, y = 275, sceneID = 1 }, { name = "", x = 158, y = 188, sceneID = 4 } }
    local nTry = 0
    local nStart = GetTickCount()
    local szMission = "#{SQXY_09061_4}"
    while true do
        if CheckItem(szMission) then
            local nIndex = GetPlayerMission_Item(szMission)
            if nIndex ~= -1 then
                if GetMissionComplete(nIndex) == 1 then
                    GoToSceneNPC(npc[1].name, npc[1].x, npc[1].y, npc[1].sceneID)
                    Sleep(600)
                    QuestFrameOptionClicked_Item(szMission, 1, 600)
                    QuestFrameNextClicked(600)
                    QuestFrameMissionComplete(0, 600)
                else
                    GoToScene(npc[2].x, npc[2].y, npc[2].sceneID, 1)
                    Sleep(500)
                    Dismount()
                    Bag:UseItemByName("愿灵泉")
                    Sleep(300)
                    PlayerStateTimeOut(5, 50)
                end
            else
                GoToSceneNPC(npc[1].name, npc[1].x, npc[1].y, npc[1].sceneID)
                Sleep(600)
                QuestFrameOptionClicked_Item(szMission, 1, 600)
                if GetNPCEventList_Item(0) == "#{SQXY_09061_7}" then
                    PushDebugMessage("许愿：已完成")
                    break
                end
                QuestFrameAcceptClicked(500)
            end
        else
            nTry = nTry + 1
            if nTry > 3 then
                PushDebugMessage("许愿：愿灵泉数量不足!")
                break
            end
        end
        if GetTickCount() - nStart > 600000 then
            PushColorMsg("许愿：10分钟超时!")
            break
        end
        DebugStr("许愿:执行中.")
        Sleep(100)
    end
    Bag_Move2TempBank(" 愿灵泉 ", 0)
    CloseAllWindow()
end
_SMain()
ScriptOnStop(m_script_name)
