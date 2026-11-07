-- 红线相忆礼随心：由 dfz64.dll 字节码模块 活动/红线相忆礼随心.lua 静态还原
-- 模块 SHA256 8742e791ea60e9a544dee50453b4f0c7e22b6d2b91c720682431e77f722b5f8a；调用、参数、等待和循环按反汇编逐条保持。
local npc = { x = 139, y = 182, sceneID = LUOYANG_ID, name = "月老" }
function _SMain()
    DeleteDebugMsg("#{JHJL_151222_05}")
    DeleteDebugMsg("#{JHJL_151222_04}")
    DeleteDebugMsg("#{JHJL_151222_13")
    GetLuaValue("setmetatable(_G, {__index = Valentine_Gift_Env});Valentine_Gift_GetClick();")
    Sleep(500)
    CloseAllWindow()
    local nStart = -1
    while true do
        GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
        if nStart == -1 then nStart = GetTickCount() end
        Sleep(500)
        QuestFrameOptionClicked_Item("#{JHJL_151222_01}", 1, 800)
        Sleep(500)
        QuestFrameOptionClicked_Item("#{JHJL_151222_01}", 1, 800)
        if IsInDebugMsg("#{JHJL_151222_05}") or IsInDebugMsg("#{JHJL_151222_08}") or IsInDebugMsg("#{JHJL_151222_13") or IsInDebugMsg("#{JHJL_151222_04}") then break end
        if GetTickCount() - nStart > 60000 then
            PushDebugMessage("领取超时")
            break
        end
        Sleep(500)
        DebugStr("领取结婚纪念品")
    end
    Bag:UseItemByName_click("眷梦情思礼包", 1000)
    Bag:UseItemByName_click("彩蝶恩爱礼匣", 1000)
    Bag:UseItemByName_click("青鸟悦爱礼匣", 1000)
    Bag:UseItemByName_click("鸳鸯痴爱礼匣", 1000)
    Bag:UseItemByName_click("鸾凤唯爱礼匣", 1000)
    Bag:UseItemByName_click("鸾凤唯爱礼匣", 1000)
end
_SMain()
