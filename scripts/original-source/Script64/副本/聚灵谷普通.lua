-- 反编译自 dfz64.dll 内嵌字节码 0030129e（unluac 2025-12-23；仅供分析）
local m_script_name = "聚灵谷普通"
ScriptOnStart(m_script_name, true, true)
LoadScript("fn聚灵谷")
CDG:InitFubenParam()
local m_param = {}
m_param.type = 2
m_param.swcq = true
m_param.unkill_xhcl = false
m_param.unkill_cyhh = false
m_param.unkill_xlbj = false
m_param.unkill_jdwj = false
m_param.unkill_ls = GetConfigBool("聚灵谷", "不打雷锁")
m_param.unkill_xg = GetConfigBool("聚灵谷", "不打小怪")
m_param.fb_count = HandleTextToNumber(GetConfigText("聚灵谷", "副本次数"), 0)
local m_data = {}
m_data.sceneID = 877
m_data.allnpc = {
  {
    name = "",
    x = 150,
    y = 146,
    sceneID = 112,
    option = "#{SESX_230426_15}",
    level = 60
  },
  {
    name = "",
    x = 156,
    y = 146,
    sceneID = 112,
    option = "#{SESX_230426_139}",
    level = 85
  },
  {
    name = "",
    x = 0,
    y = 0,
    sceneID = 201,
    option = "#{SESX_230426_140}"
  },
  {
    name = "",
    x = 0,
    y = 0,
    sceneID = 875,
    option = "#{SESX_230426_140}"
  }
}

function _SMain(...)
  local bOver = false
  local npc = m_data.allnpc[m_param.type]
  local bOldComp, nOldMyCount, nOldAllCount = IsHuodongComplete("灵谷勘兽迹", 1, true)
  if GetSceneID() == m_data.sceneID then
    nOldMyCount = nOldMyCount - 1
  end
  while true do
    local curScene = GetSceneID()
    if curScene == m_data.sceneID then
      bOver = true
      JLG_Fuben(m_param)
    else
      if 0 == m_param.fb_count and bOver then
        LogMsg("聚灵谷:本次已完成")
        break
      end
      local bNowComp, nNowMyCount, nNowAllCount = IsHuodongComplete("灵谷勘兽迹", 1)
      if bNowComp then
        Sleep(2000)
        if GetSceneID() ~= m_data.sceneID and IsHuodongComplete("灵谷勘兽迹", 1, true) then
          LogMsg("聚灵谷:本周已刷满")
          break
        end
      else
        if 0 ~= m_param.fb_count and nNowMyCount - nOldMyCount >= m_param.fb_count and GetSceneID() ~= m_data.sceneID then
          LogMsg(m_script_name .. ":已经完成" .. m_param.fb_count .. "次")
          break
        end
        if IsKVKSceneName() then
          Player:TeamFollow(false, 300)
        end
        GoToScene(153, 146, npc.sceneID)
        ChangeSceneLine()
        local tObj = Enum2XByName(" 剧毒乌犍 玄雷宝驹 雪海沧龙 赤焰黑虎 ", {
          1,
          0,
          0,
          0
        }, nil, nil, 3)
        for i = 1, #tObj do
          local tmp = tObj[i]
          if tmp.level == npc.level then
            TalkNpc(tmp.name, 800)
            QuestFrameOptionClicked_Item(npc.option, 1, 1000)
            break
          end
        end
      end
    end
    Sleep(500)
    DebugStr(m_script_name)
  end
  Player:TeamFollow(false, 300)
end

_SMain()
ScriptOnStop(m_script_name, true)
