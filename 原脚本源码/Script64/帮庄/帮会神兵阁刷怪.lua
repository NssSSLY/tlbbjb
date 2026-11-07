-- 反编译自 dfz64.dll 内嵌字节码 00351748（unluac 2025-12-23；仅供分析）
local m_script_name = "刷怪神兵阁"
ScriptOnStart(m_script_name, true, false)

function _SMain(...)
  SG_ParseConfig()
  LeaveSpecialScene(nil, nil)
  CDG:InitDaguaiParam()
  if not g_config.shuaguai.unuse_skill then
    CDG.skill_attack = g_config.skill.shuaguai_gongji
  else
    CDG.skill_attack = {}
  end
  CDG.skill_state = g_config.skill.shuaguai_zhuangtai
  CDG.skill_comb1 = g_config.skill.shuaguai_zuhe1
  CDG.skcb1.using = false
  CDG.skcb1.mode = g_config.skill.shuaguai_zuhe1_use.sel
  CDG.skill_comb2 = g_config.skill.shuaguai_zuhe2
  CDG.skcb2.using = false
  CDG.skcb2.mode = g_config.skill.shuaguai_zuhe2_use.sel
  local temp1 = ReadConfigInt("ZH", "bjk146")
  local temp2 = ReadConfigInt("ZH", "bjk147")
  CDG.pos = {
    {x = temp1, y = temp2}
  }
  CDG.targetName = ""
  CDG.die.out = true
  CDG.die.waittime = -1
  CDG.die.maxCount = 0
  CDG.back.buypetRation = false
  CDG.back.buypetHappy = false
  CDG.back.buyhy = false
  CDG.back.fullprop = false
  CDG.back.fullmate = false
  CDG.back.fullbag = false
  CDG.energy.check = false
  CDG.overMapErr = true
  if CDG.attackMode == "普通抢怪" or CDG.attackMode == "超级抢怪" then
    CDG.attackMode = "优先绿怪"
  end
  if #CDG.petArr > 0 then
    PushColorMsg("刷怪:有%d只珍兽需要练级", #CDG.petArr)
  end
  DeleteDebugMsg("#{SBG_140512_66}")
  DeleteDebugMsg("#{SBG_140512_69}")
  while true do
    local nowSceneName = GetCurrentSceneName()
    if string.find(nowSceneName, "神兵", nil, true) then
      CDG.sceneName = nowSceneName
      CDG.sceneID = GetSceneID()
      if CDG:OnStart() then
        break
      end
    elseif "" ~= nowSceneName then
      if GoToGuild() then
        GoToSceneNPC("武强盛", 130, 126, -1, nil, nil, nil, MoveCallback_InMyGuild)
        Sleep(500)
        if -1 ~= Player:GetBuff("进入神兵阁") then
          QuestFrameOptionClicked_Item("#{SBG_140512_06}", 1, 1000)
          QuestFrameOptionClicked_Item("#{SBG_140512_45}", 1, 800)
        else
          QuestFrameOptionClicked_Item("#{SBG_140512_05}", 1, 1000)
          QuestFrameOptionClicked_Item("#{SBG_140512_60}", 1, 1000)
          if IsInDebugMsg("#{SBG_140512_69}") then
            PushDebugMessage("神兵阁:您今日已经参加过")
            break
          elseif IsInDebugMsg("#{SBG_140512_66}") then
            PushDebugMessage("神兵阁:帮会未开启")
            break
          end
        end
      else
        PushColorMsg(m_script_name .. ":没有帮派城市！")
        break
      end
    end
    Sleep(500)
  end
  while true do
    local nowSceneName = GetCurrentSceneName()
    if string.find(nowSceneName, "神兵", nil, true) then
      RunTo(165, 253)
    else
      break
    end
    Sleep(3000)
    DebugStr("离开神兵阁")
  end
  DoubleExp_Freeze()
end

_SMain()
ScriptOnStop(m_script_name)
