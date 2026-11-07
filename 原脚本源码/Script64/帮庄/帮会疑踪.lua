-- 反编译自 dfz64.dll 内嵌字节码 00350c2c（unluac 2025-12-23；仅供分析）
local m_script_name = "帮会疑踪"
ScriptOnStart(m_script_name, true, false)
local m_param = {}
m_param.leader = ""

local function BHNZ_check_border(_aPos)
  if _aPos.y < 119 then
    return false
  end
  if _aPos.x > 156 then
    return false
  end
  if _aPos.x > 147 and _aPos.y > 138 then
    return false
  end
  if _aPos.x > 122 and _aPos.x < 137 and _aPos.y < 125 then
    return false
  end
  if _aPos.x < 51 then
    return false
  end
  if _aPos.x < 63 and _aPos.y < 129 then
    return false
  end
  if _aPos.x < 63 and _aPos.y > 140 and _aPos.y < 146 then
    return false
  end
  return true
end

local function BHNZ_CheckXianJin(aBoss)
  local bHave, bSafe = false, true
  local tObj = EnumUnSafeSpecial("神雷陷阱")
  if #tObj > 0 then
    bHave = true
    bSafe = FubenTrapRun("", aBoss.x, aBoss.y, 5, 15, tObj, BHNZ_check_border, FubenRunSafe)
  end
  return bHave, bSafe
end

function _SMain(...)
  PushDebugMessage("组队页面可设置暂停此脚本自动组队")
  local bChange = false
  local checkTick = GetTickCount() - 60000
  while true do
    local debugnote = ""
    if IsMyGuildCity() then
      if 9 == Player:GetState() then
        debugnote = " 角色死亡"
        DieRelive(0)
      else
        PickUpLua()
        local tObj = Enum2XByName("影傀", {
          0,
          1,
          0,
          0
        }, {0, -1}, nil, 0)
        if #tObj > 0 or GetTickCount() - checkTick < 10000 then
          if #tObj > 0 then
            local tmp = tObj[1]
            checkTick = GetTickCount()
            local bHave, bSafe = BHNZ_CheckXianJin(tmp)
            if not bHave or bSafe and not g_self.isjingong then
              if tmp.dst > 5 and not bHave then
                RunTo(tmp.x, tmp.y, 0, 800)
                PlayerStateTimeOut(2, 5)
              end
              FubenAttack(tmp.id)
            end
          else
            debugnote = " 等待捡包"
            for i = 1, 5 do
              FubenAttack(-1)
              RelivePlayer(1, nil, nil, nil, nil, false)
              PickUpLua()
            end
          end
        elseif Player:IsLeader() then
          local tTtem = Bag:FindItemInfo("青竹短哨")
          if #tTtem > 0 then
            Dismount(600)
            Bag:UseItemByName("青竹短哨", 600)
            MessageBox_Self2_OK_Clicked(800)
            local nMsgTime, strMsg = IsInDebugMsg("#{BPSL_Boss_210716_26")
            if nMsgTime then
              local _, _, xPos, yPos = string.find(strMsg, "#{BPSL_Boss_210716_26.-(%d+).-(%d+)}")
              xPos = tonumber(xPos)
              yPos = tonumber(yPos)
              if xPos and yPos then
                MoveTo(xPos, yPos, -1, nil, nil, MoveCallBack_state_2, MoveCallback_InMyGuild)
                Dismount()
                Bag:UseItemByName("青竹短哨", 600)
                PlayerStateTimeOut(5, 5)
              end
            end
          else
            local nCount = Team:GetMemberCount()
            if nCount > 1 then
              GetLuaValue(fmt("Player:AppointLeader(%d)", nCount - 1))
            end
            if bChange then
              break
            end
            bChange = true
          end
        else
          GoToLeader(nil, MoveCallBack_state_2)
        end
      end
    else
      GoToGuild()
    end
    Sleep(800)
    DebugStr(m_script_name .. debugnote)
  end
end

_SMain()
ScriptOnStop(m_script_name, false)
