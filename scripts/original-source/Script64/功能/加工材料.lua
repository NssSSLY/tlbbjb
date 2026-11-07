-- 反编译自 dfz64.dll 内嵌字节码 00336540（unluac 2025-12-23；仅供分析）
local m_script_name = "加工材料"
ScriptOnStart(m_script_name, false, false)

function _SMain(...)
  while true do
    local nState = Player:GetState()
    if 0 == nState then
      Player:TeamFollow(false, 500)
      Dismount()
      if JiaGongCaiLiao() == false and false == TempBank2Bag("高级皮毛", 0) and false == TempBank2Bag("工艺材料", 0) and false == TempBank2Bag("缝纫类材", 0) and false == TempBank2Bag("铸造类材", 0) then
        break
      end
      ClearBag()
      local nSpace = Bag:GetSpaceNum(1)
      if 0 == nSpace then
        ClearBag()
        Sleep(200)
        if 0 == Bag:GetSpaceNum(1) then
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
