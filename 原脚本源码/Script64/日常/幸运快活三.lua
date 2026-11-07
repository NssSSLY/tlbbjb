-- 反编译自 dfz64.dll 内嵌字节码 00429270（unluac 2025-12-23；仅供分析）
local m_script_name = "幸运快活三"
ScriptOnStart(m_script_name)

local function xyIsComplete()
  local str = [[
            local cnt = 0
            setmetatable(_G, {__index = XingYun_Env})
            local TBL_Head = {}
            TBL_Head[1] = XingYun_Head1
            TBL_Head[2] = XingYun_Head2
            TBL_Head[3] = XingYun_Head3
            TBL_Head[4] = XingYun_Head4
            TBL_Head[5] = XingYun_Head5
            TBL_Head[6] = XingYun_Head6
            TBL_Head[7] = XingYun_Head7
            TBL_Head[8] = XingYun_Head8
            TBL_Head[9] = XingYun_Head9
            TBL_Head[10] = XingYun_Head10
            TBL_Head[11] = XingYun_Head11
            TBL_Head[12] = XingYun_Head12
            TBL_Head[13] = XingYun_Head13
            TBL_Head[14] = XingYun_Head14
            TBL_Head[15] = XingYun_Head15
            TBL_Head[16] = XingYun_Head16
            TBL_Head[17] = XingYun_Head17
            TBL_Head[18] = XingYun_Head18
            TBL_Head[19] = XingYun_Head19
            TBL_Head[20] = XingYun_Head20
            for i = 1, 20 do
                if TBL_Head[i]:GetToolTip() == "" then
                    cnt = cnt + 1
                end
            end
            return cnt
        ]]
  local cnt = GetLuaValue(str, "n")
  if 20 == cnt then
    return true
  end
  return false
end

function _SMain(...)
  local tick_out = -1
  local click = {}
  while true do
    if IsWindowVisible("XingYun") == false then
      GoToSceneNPC("柳月虹", 230, 350, 1)
      Sleep(600)
      QuestFrameOptionClicked_Item("幸运快活三", 1, 800)
      local szText = GetNPCEventList_Item(0)
      if string.find(szText, "已经参加", nil, true) then
        for i = 1, 6 do
          GoToSceneNPC("柳月虹", 230, 350, 1)
          QuestFrameOptionClicked_Item("领取幸运快活三奖励", 1, 800)
          local szText = GetNPCEventList_Item(0)
          if "#{XYLP_20071222_02}" == szText then
            goto lbl_150
          end
          Sleep(500)
        end
        break
      elseif string.find(szText, "再等60分钟", nil, true) then
        PushDebugMessage("幸运快活三：距离上次参加快活三的时间太短")
        break
      end
    else
      math.randomseed(GetTickCount())
      local idx = math.random(1, 20)
      local check = true
      for i = 1, #click do
        if click[i] == idx then
          check = false
          break
        end
      end
      if check then
        table.insert(click, idx)
        GetLuaValue(fmt("setmetatable(_G, {__index = XingYun_Env});Play_Ani(%d)", idx))
        Sleep(1000)
      end
      if xyIsComplete() then
        PushDebugMessage("快活三任务完成！")
        GetLuaValue("setmetatable(_G, {__index = XingYun_Env});XingYun_Close()")
      end
    end
    if -1 == tick_out then
      tick_out = GetTickCount()
    end
    if -1 ~= tick_out and GetTickCount() - tick_out > 60000 then
      PushColorMsg(m_script_name .. ":执行超时")
      break
    end
    Sleep(1000)
    DebugStr("幸运快活三")
  end
  ::lbl_150::
  CloseAllWindow()
end

_SMain()
ScriptOnStop(m_script_name)
