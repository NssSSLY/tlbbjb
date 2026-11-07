-- 反编译自 dfz64.dll 内嵌字节码 0044d295（unluac 2025-12-23；仅供分析）
local m_script_name = "虞花苦渡(困难)"
ScriptOnStart(m_script_name, true, true)
local METEOR_SAFE_RADIUS = 8
local METEOR_WARN_DIST = 15

function YJSH_OnDie(...)
  DieRelive(0)
  if 9 == Player:GetState() then
    DieRelive(-1)
    local tSYJ = Enum2XByName("溯缘镜", {
      1,
      0,
      0,
      0
    }, {0, -1}, nil, 0)
    if #tSYJ > 0 then
      local tmp = tSYJ[1]
      OpenTalk(tmp.id, 600)
      Dismount()
      Sleep(1000)
      QuestFrameOptionClicked_Item("#{QXFB_260529_279}", 1, 1000)
      Sleep(1000)
      QuestFrameOptionClicked_Item("#{QXFB_260529_33}", 1, 1000)
      Sleep(1000)
      QuestFrameOptionClicked_Item("#{QXFB_260529_30}", 1, 1000)
    end
  end
  return true
end

local function HandleMeteorTraps(boss)
  local traps = Enum2XByClass("陷阱")
  for _, trap in ipairs(traps) do
    PushColorMsg(trap.name)
    if trap.name == "关卡3boss技能c" then
      PushColorMsg("躲技能啊")
      local param = {useqg = true, usesx = true}
      local isSafe = FubenTrapRun("", boss.x, boss.y, 5, 15, traps, nil, FubenRunSafe, nil, nil, param)
      if not isSafe then
        FubenAttack(-1)
        return false
      end
    end
  end
  return true
end

function onstar()
  GetLuaValue([[
            if _QiXi_PVE_Info_OnEvent == nil then
                __QiXi_PVE_Info = ""
               
                _QiXi_PVE_Info_OnEvent = QiXi_PVE_Info_OnEvent;
            end

            function QiXi_PVE_Info_OnEvent(event)
                if(event == "UI_COMMAND") then
                    if tonumber(arg0) == 05123801 then
                        __QiXi_PVE_Info = Get_XParam_STR( 0 )
                        __QiXi_PVE_Info = __QiXi_PVE_Info.."|"..Get_XParam_STR( 1 )
                        __QiXi_PVE_Info = __QiXi_PVE_Info.."|"..Get_XParam_STR( 2 )
                        __QiXi_PVE_Info = __QiXi_PVE_Info.."|"..Get_XParam_STR( 3 )
                        __QiXi_PVE_Info = __QiXi_PVE_Info.."|"..Get_XParam_STR( 4 )
                        
                        __QiXi_PVE_Info = __QiXi_PVE_Info.."|"..tostring(Get_XParam_INT( 1 ))
                        __QiXi_PVE_Info = __QiXi_PVE_Info.."|"..tostring(Get_XParam_INT( 2 ))
                        __QiXi_PVE_Info = __QiXi_PVE_Info.."|"..tostring(Get_XParam_INT( 3 ))
                        __QiXi_PVE_Info = __QiXi_PVE_Info.."|"..tostring(Get_XParam_INT( 4 ))
                        __QiXi_PVE_Info = __QiXi_PVE_Info.."|"..tostring(Get_XParam_INT( 5 ))
                        __QiXi_PVE_Info = __QiXi_PVE_Info.."|"..tostring(Get_XParam_INT( 6 ))
                        __QiXi_PVE_Info = __QiXi_PVE_Info.."|"..tostring(Get_XParam_INT( 7 ))
                        __QiXi_PVE_Info = __QiXi_PVE_Info.."|"..tostring(Get_XParam_INT( 8 ))
                        __QiXi_PVE_Info = __QiXi_PVE_Info.."|"..tostring(Get_XParam_INT( 9 ))
                        __QiXi_PVE_Info = __QiXi_PVE_Info.."|"..tostring(Get_XParam_INT( 10 ))
                        __QiXi_PVE_Info = __QiXi_PVE_Info.."|"..tostring(Get_XParam_INT( 11 ))
                        __QiXi_PVE_Info =  __QiXi_PVE_Info.."|"..tostring(Get_XParam_INT( 12 ))
                                
                    end
                end
                _QiXi_PVE_Info_OnEvent(event)
            end
        ]])
  while GetSceneID() == 1079 do
    local s = GetLuaValue("return __QiXi_PVE_Info", "s", 1)
    local fields = {}
    for part in string.gmatch(s, "([^|]*)") do
      table.insert(fields, part)
    end
    local f11 = fields[11]
    local f12 = fields[12]
    PushColorMsg(f11)
    PushColorMsg(f12)
    FuBenCheckDie(false, true, YJSH_OnDie())
    local tYJ = Enum2XByName("虞姬", {
      1,
      0,
      0,
      0
    }, {0, -1}, nil, 0)
    if #tYJ > 0 then
      local tmp = tYJ[1]
      OpenTalk(tmp.id, 600)
      Sleep(1000)
      QuestFrameOptionClicked_Item("#{QXFB_260529_257}", 1, 1000)
    end
    local tYGST = Enum2XByName("虞姬尸体", {
      1,
      0,
      0,
      0
    }, {0, -1}, nil, 0)
    if #tYGST > 0 then
      local tYGYJNPC = Enum2XByName("怨骨虞姬", {
        1,
        1,
        0,
        0
      }, {0, -1}, nil, 0)
      local tYGYJGW = Enum2XByName("怨骨虞姬", {
        0,
        1,
        0,
        0
      }, {0, -1}, nil, 0)
      tYGYJGW = ObjFilterByTitle(tYGYJGW, " #{QXFB_260529_353} #{QXFB_260529_354} #{QXFB_260529_355} ", 3)
      if #tYGYJGW > 0 then
        for i = 1, #tYGYJGW do
          if tYGYJGW[i].class == "怪物" and string.find(tYGYJGW[i].title, "#{QXFB_260529_35", nil, true) then
            local boss = tYGYJGW[i]
            PushColorMsg(boss.hp)
            local safeToAttack = HandleMeteorTraps(boss)
            if safeToAttack then
              do
                local tHGZG = Enum2XByName(" 化骨伥鬼 怨血镜魔 ", {
                  0,
                  1,
                  0,
                  0
                }, {0, -1}, nil, 3)
                if #tHGZG > 0 then
                  local boss = tHGZG[1]
                  FubenAttack(boss.id)
                  Sleep(200)
                  if f11 == f12 then
                    Sleep(200)
                  else
                    goto lbl_363
                  end
                end
                if f11 == f12 then
                  if tYGYJGW[i].hp > 15 then
                    FubenAttack(boss.id)
                    goto lbl_363
                  end
                  StopAttack(boss, {
                    x = boss.x,
                    y = boss.y
                  })
                  if 4 == g_self.menpai then
                    PushColorMsg("峨眉继续加血")
                    do
                      local add_hp_name = CDG:checkHP_Player()
                      if "" == add_hp_name then
                        CDG:checkHP(false)
                      else
                        Dismount()
                      end
                      CDG:checkHP_Pet(false)
                      CDG:checkMP(true)
                      Sleep(200)
                    end
                    goto lbl_363
                  end
                  PushColorMsg("")
                  Sleep(200)
                end
              end
              goto lbl_363
            end
            FubenAttack(-1)
            goto lbl_363
          end
        end
      elseif #tYGYJNPC > 0 then
        for i = 1, #tYGYJNPC do
          if tYGYJNPC[i].class == "NPC" then
            local boss = tYGYJNPC[i]
            OpenTalk(boss.id, 600)
            Sleep(1000)
            QuestFrameOptionClicked_Item("#{QXFB_260529_231}", 1, 1000)
            goto lbl_363
          end
        end
      else
        local tmp = tYGST[1]
        OpenTalk(tmp.id, 600)
        Sleep(1000)
        QuestFrameOptionClicked_Item("#{QXFB_260529_43}", 1, 1000)
        Sleep(1000)
        QuestFrameOptionClicked_Item("#{QXFB_260529_35}", 1, 1000)
      end
    else
      local tSYJ = Enum2XByName("溯缘镜", {
        1,
        0,
        0,
        0
      }, {0, -1}, nil, 0)
      if #tSYJ > 0 then
        local tmp = tSYJ[1]
        OpenTalk(tmp.id, 600)
        Dismount()
        Sleep(1000)
        QuestFrameOptionClicked_Item("#{QXFB_260529_279}", 1, 1000)
        Sleep(1000)
        QuestFrameOptionClicked_Item("#{QXFB_260529_33}", 1, 1000)
        Sleep(1000)
        QuestFrameOptionClicked_Item("#{QXFB_260529_30}", 1, 1000)
      end
    end
    ::lbl_363::
  end
end

function _SMain(...)
  if GetSceneID() ~= 1079 then
    GoToSceneNPC("卖花女", 122, 134, 1075)
    Sleep(1000)
    QuestFrameOptionClicked_Item("#{QXZH_250528_42}", 1, 1000)
    Sleep(1000)
    GoToSceneNPC("花匠", 174, 188, 1075)
    Sleep(1000)
    QuestFrameOptionClicked_Item("#{QXZH_250528_113}", 1, 1000)
    Sleep(1000)
  end
  while true do
    DeleteDebugMsg("#{QXFB_260529_347}")
    DeleteDebugMsg("#{QXFB_260529_15}")
    if GetSceneID() == 1079 then
      onstar()
    else
      GoToSceneNPC("溯缘镜", 208, 51, 1075)
      Dismount()
      Sleep(1000)
      if IsTeamSteady() then
        QuestFrameOptionClicked_Item("#{QXFB_260529_05}", 1, 1000)
        Sleep(1000)
        QuestFrameOptionClicked_Item("#{QXFB_260529_06}", 1, 1000)
        if IsInDebugMsg("#{QXFB_260529_347}") or IsInDebugMsg("#{QXFB_260529_15}") then
          PushColorMsg("#{QXFB_260529_347}")
          QuestFrameOptionClicked_Item("#{QXFB_260529_06}", 1, 1000)
          break
        end
        QuestFrameOptionClicked_Item("#{QXFB_260529_06}", 1, 1000)
      end
    end
  end
end

PushColorMsg(GetSceneID())
_SMain()
ScriptOnStop(m_script_name, true)
