-- 宝石雕琢：由 dfz64.dll 字节码模块 功能/宝石雕琢.lua 静态还原
-- 模块 SHA256 c4802536edafa3c93816419d988262b24e2770d2e4c2bc9dd9cb6d482c303762；宝石等级判断、雕琢符等级对应、先锦囊后仓库、雕琢请求与结束条件按反汇编保持；原程序设置页的宝石名单与绑定选项改为任务设置；材料栏宝石的绑定状态读不到，只支持“绑定和不绑定都勾选”（混用，雕琢符优先用绑定的）；开头清包（删除物品）与结束后存仓未接入。
local m_script_name = "宝石雕琢"
ScriptOnStart(m_script_name, false, false)
local cfg = TaskConfig or {}
local bBind, bUnBind = cfg.bsdz_bind == true, cfg.bsdz_unbind == true
local szGem = tostring(cfg.bsdz_list or ""):gsub("（", "("):gsub("）", ")")
local tItem = {}
for name in szGem:gmatch("%S+") do table.insert(tItem, name) end
local function Carve()
    local bAny = false
    for _ = 1, 100 do
        local bOnce = false
        for _, name in ipairs(tItem) do
            if GemCarve(name) == 1 then
                bOnce = true
                bAny = true
                Sleep(100)
                break
            end
        end
        if Bag:GetSpaceNum(1) == 0 then
            if bAny then PushColorMsg("材料包已满") end
            break
        end
        if not bOnce then break end
        Sleep(300)
    end
    return bAny
end
function _SMain()
    if not bBind and not bUnBind then
        PushDebugMessage(m_script_name .. ":您还为设置雕琢宝石的绑定类型")
        return
    end
    if not (bBind and bUnBind) then
        PushColorMsg(m_script_name .. "：材料栏宝石的绑定状态读不到，只支持绑定和不绑定都勾选（混用）")
        return
    end
    if #tItem == 0 then return end
    local szFu = " "
    for lv = 1, 3 do
        if string.find(szGem, lv .. "级", 1, true) then szFu = szFu .. "宝石雕琢符" .. lv .. "级 " end
    end
    TempBank2Bag(szFu)
    local tNpc = { x = 281, y = 321, sceneID = LUOYANG_ID, name = "彭怀玉" }
    local nStart = GetTickCount()
    while true do
        GoToSceneNPC(tNpc.name, tNpc.x, tNpc.y, tNpc.sceneID)
        Sleep(500)
        if not Carve() then
            TempBank2Bag(szGem)
            TempBank2Bag(szFu)
            Sleep(500)
            if not Carve() then
                Bank_GetItem(szGem)
                Bank_GetItem(szFu, -1)
                GoToSceneNPC(tNpc.name, tNpc.x, tNpc.y, tNpc.sceneID)
                if not Carve() then
                    PushDebugMessage(m_script_name .. ":已经没有可以雕琢的宝石或雕琢符")
                    break
                end
            end
        end
        if GetTickCount() - nStart > 300000 then
            PushDebugMessage(m_script_name .. ":超时!")
            break
        end
        Sleep(500)
        DebugStr(m_script_name)
    end
end
_SMain()
ScriptOnStop(m_script_name)
