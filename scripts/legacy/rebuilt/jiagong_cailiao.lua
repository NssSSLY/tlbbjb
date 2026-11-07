-- 加工材料：由 dfz64.dll 字节码模块 功能/加工材料.lua 静态还原
-- 模块 SHA256 48fb425b8b49b81424dcda239b7f0576d054c929833ad45940c1babf7d11448a；判断顺序与等待按反汇编保持；配方选择见 compat.lua 的 JiaGongCaiLiao（“工艺材料”配方 407 未接入）；原规则的停止跟随与清理背包不执行。
local m_script_name = "加工材料"
ScriptOnStart(m_script_name, false, false)
function _SMain()
    while true do
        if Player:GetState() == 0 then
            -- 原规则先停止跟随（Player:TeamFollow(false)），未接入
            Dismount()
            if JiaGongCaiLiao() == false then
                if TempBank2Bag("高级皮毛", 0) == false and TempBank2Bag("工艺材料", 0) == false
                    and TempBank2Bag("缝纫类材", 0) == false and TempBank2Bag("铸造类材", 0) == false then
                    break
                end
            end
            -- 原规则此处清理背包（ClearBag），不执行
            if Bag:GetSpaceNum(1) == 0 then
                Sleep(200)
                if Bag:GetSpaceNum(1) == 0 then
                    PushDebugMessage(m_script_name .. ":背包已满！")
                    break
                end
            end
        end
        Sleep(300)
        DebugStr(m_script_name)
    end
end
_SMain()
ScriptOnStop(m_script_name)
