-- 乱匪密函换棉布：由 dfz64.dll 字节码模块 其他/乱匪密函换棉布.lua 静态还原
-- 模块 SHA256 95e07ecd9d89f810cfc63393352b1e25189ea7a2da88bdfd35da7d1e20f7699f；NPC、对话选项与交付按反汇编保持；原规则的数量判断写成“大于等于 0”，永远不会因数量不足停下，这里按兑换所需的 42 个判断；最多 100 轮。
local m_script_name = "乱匪密函兑换"
function _SMain()
    local tNpc = { name = "苏辙", x = 258, y = 165, sceneID = LUOYANG_ID }
    for _ = 1, 100 do
        if Bag:GetItemCount("乱匪密函") < 42 then
            PushColorMsg("乱匪密函数量不足")
            break
        end
        if DialogOptionClicked("上缴乱匪密函换取封赏", 1, 600) then
            DialogOptionClicked("42个乱匪密函兑换封赏", 1, 600)
            QuestFrameMissionComplete(1, 200)
        else
            GoToSceneNPC(tNpc.name, tNpc.x, tNpc.y, tNpc.sceneID)
            Sleep(200)
        end
        Sleep(200)
        DebugStr(m_script_name)
    end
end
_SMain()
