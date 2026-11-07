-- 凝聚九天玉碎：由 dfz64.dll 字节码模块 功能/凝聚九天玉碎.lua 静态还原
-- 模块 SHA256 58fad56e07fde19ee5afa8a1449322a16ae3b422d5a26424b9487dda102bb177；NPC、界面操作、判断与 300 秒上限按反汇编保持；原程序“设置”页三个下拉框改为任务设置的数字（攻击/抗性 0 表示跟随角色攻击属性）；读不到攻击属性时停止，不发送无效选择。
local m_script_name = "凝聚九天玉碎"
ScriptOnStart(m_script_name, false, false)
local cfg = TaskConfig or {}
local gj = math.floor(tonumber(cfg.cohesion_attack) or 0)
local kx = math.floor(tonumber(cfg.cohesion_resist) or 0)
local cc = math.floor(tonumber(cfg.cohesion_pierce) or 0) + 1
function _SMain()
    local npc = { x = 115, y = 199, sceneID = 850, name = "杜钏灵" }
    local szItem = "九天玉碎"
    TempBank2Bag(szItem)
    if Bag:GetItemCount(szItem) == 0 then Bank_GetItem(szItem) end
    local nAttr = PlayerAttackAttr()
    if gj <= 0 then gj = nAttr end
    if kx <= 0 then kx = nAttr end
    if cc <= 0 then cc = 1 end
    if gj < 0 or kx < 0 then
        PushColorMsg(m_script_name .. ":读不到角色攻击属性，请在任务设置里指定攻击和抗性")
        return
    end
    local nStart = -1
    CloseAllWindow()
    while true do
        if IsWindowVisible("EquipBaoJian_Cohesion") then
            local nNeed, nMoney = CohesionCost()
            if Bag:GetItemCount(szItem) < nNeed then
                PushColorMsg(m_script_name .. ":数量不足")
                break
            end
            if Player:GetMoney() + Player:GetMoney(2) < nMoney then
                PushColorMsg(m_script_name .. ":金币不足")
                break
            end
            GetLuaValue("setmetatable(_G, {__index = EquipBaoJian_Cohesion_Env});EquipBaoJian_Cohesion_OnOK();")
            Sleep(500)
            if IsWindowVisible("EquipBaoJian_YuLuan_Tips") then
                GetLuaValue(string.format("setmetatable(_G, {__index = EquipBaoJian_YuLuan_Tips_Env});EquipBaoJian_YuLuan_Tips_OnSelect(%d);", gj))
                Sleep(600)
                CloseWindow("EquipBaoJian_YuLuan_Tips")
                Sleep(600)
            elseif IsWindowVisible("EquipBaoJian_TianHuo_Tips") then
                GetLuaValue(string.format("setmetatable(_G, {__index = EquipBaoJian_TianHuo_Tips_Env});EquipBaoJian_TianHuo_Tips_OnSelect(%d);", kx))
                Sleep(600)
                CloseWindow("EquipBaoJian_TianHuo_Tips")
                Sleep(600)
            elseif IsWindowVisible("EquipBaoJian_YunShui_Tips") then
                GetLuaValue(string.format("setmetatable(_G, {__index = EquipBaoJian_YunShui_Tips_Env});EquipBaoJian_YunShui_Tips_OnSelect(%d);", cc))
                Sleep(600)
                CloseWindow("EquipBaoJian_YunShui_Tips")
                Sleep(600)
            end
        else
            GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
            DialogOptionClicked("五行宝玉凝聚", 1, 800)
        end
        if nStart == -1 then nStart = GetTickCount() end
        if GetTickCount() - nStart > 300000 then
            PushColorMsg(m_script_name .. "：执行超时")
            break
        end
        Sleep(500)
        DebugStr(m_script_name)
    end
    CloseAllWindow()
end
_SMain()
ScriptOnStop(m_script_name)
