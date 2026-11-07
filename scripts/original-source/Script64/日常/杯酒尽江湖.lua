-- 反编译自 dfz64.dll 内嵌字节码 0042af8e（unluac 2025-12-23；仅供分析）
local m_script_name = "杯酒尽江湖"
ScriptOnStart(m_script_name)
g_config["杯酒尽江湖"] = {}
g_config["杯酒尽江湖"]["运行时间"] = GetConfigText("杯酒尽江湖", "运行时间")
g_config["杯酒尽江湖"]["斟酒名单"] = GetConfigText("杯酒尽江湖", "斟酒名单")
local m_param = {}
m_param.maxTick = HandleTextToNumber(g_config["杯酒尽江湖"]["运行时间"], 10)
m_param.strName = g_config["杯酒尽江湖"]["斟酒名单"]
local m_data = {}
m_data.filter = {}

local function BJJJH_Action()
  m_param.obj_zj = Text2Table(m_param.strName, " ", "name")
  for i = 1, #m_param.obj_zj do
    m_param.obj_zj[i].zhenjiu = false
  end
  m_param.maxTick = m_param.maxTick * 60 * 1000
  table.insert(m_data.filter, g_self.name)
  local jutan = {
    x = 399,
    y = 224,
    name = "酒坛"
  }
  local zhenjiu = {
    x = 402,
    y = 224,
    name = "酒桌"
  }
  local npc = {
    x = 404,
    y = 224,
    name = "嵇竹叶"
  }
  DeleteDebugMsg("#{BJJH_221024_66}")
  DeleteDebugMsg("#{BJJH_221024_100}")
  while true do
    GoToScene(jutan.x, jutan.y, LUOYANG_ID)
    Player:TeamFollow(false, 300)
    Dismount(500)
    local tObj = Enum2XByName("酒坛", {
      1,
      0,
      0,
      0
    }, nil, nil, 0)
    if #tObj > 0 then
      local tmp = tObj[1]
      Skill.CUseSkillByID(4830, tmp.id, -1, -1)
      Sleep(1000)
      PlayerStateTimeOut(2, 5)
      PlayerStateTimeOut(5, 5)
      PlayerStateTimeOut(7, 5)
    end
    if IsInDebugMsg("#{BJJH_221024_66}") or IsInDebugMsg("#{BJJH_221024_100}") then
      break
    end
    Sleep(500)
    DebugStr("喝酒中")
  end
  local oldTick = GetTickCount()
  local jiuzhuoID = -1
  DeleteDebugMsg("#{BJJH_221024_87}")
  while true do
    GoToScene(zhenjiu.x, zhenjiu.y, LUOYANG_ID)
    Player:TeamFollow(false, 300)
    Dismount(500)
    local tMingDan = {}
    DeleteDebugMsg("#{BJJH_221024_68}")
    DeleteDebugMsg("#{BJJH_221024_88}")
    DeleteDebugMsg("#{BJJH_221024_70")
    if -1 == jiuzhuoID then
      local tJZ = Enum2XByName("酒桌", {
        1,
        0,
        0,
        0
      }, nil, nil, 0)
      if #tJZ > 0 then
        jiuzhuoID = tJZ[1].id
      end
    end
    if #m_param.obj_zj > 0 then
      local bOver = true
      for i = 1, #m_param.obj_zj do
        if not m_param.obj_zj[i].zhenjiu then
          bOver = false
        end
      end
      if bOver then
        PushColorMsg("斟酒名单已完成")
        break
      end
      if -1 ~= jiuzhuoID then
        local tObj = Enum2XByName(m_param.strName, {
          0,
          0,
          1,
          0
        }, nil, nil, 3)
        for j = 1, #tObj do
          local tmp = tObj[j]
          if false == FindTableValue(m_data.filter, tmp.name) then
            Skill.CUseSkillByID(4831, jiuzhuoID, -1, -1)
            Sleep(1000)
            PlayerStateTimeOut(2, 5)
            PlayerStateTimeOut(5, 5)
            Sleep(1000)
            SP_ZhenJiu(tmp.id)
            Sleep(1000)
            if IsInDebugMsg("#{BJJH_221024_68}") or IsInDebugMsg("#{BJJH_221024_88}") or IsInDebugMsg("#{BJJH_221024_70") then
              PushColorMsg("排除玩家：" .. tmp.name)
              table.insert(m_data.filter, tmp.name)
              for i = 1, #m_param.obj_zj do
                if m_param.obj_zj[i].name == tmp.name then
                  m_param.obj_zj[i].zhenjiu = true
                end
              end
            end
            break
          end
        end
      end
    elseif -1 ~= jiuzhuoID then
      local tObj = Enum2XByClass("玩家")
      for i = 1, #tObj do
        local tmp = tObj[i]
        if tmp.level >= 15 and false == FindTableValue(m_data.filter, tmp.name) and IsPlayerIsFriend(tmp.name) then
          Skill.CUseSkillByID(4831, jiuzhuoID, -1, -1)
          Sleep(1000)
          PlayerStateTimeOut(2, 5)
          PlayerStateTimeOut(5, 5)
          Sleep(1000)
          SP_ZhenJiu(tmp.id)
          Sleep(1000)
          if IsInDebugMsg("#{BJJH_221024_68}") or IsInDebugMsg("#{BJJH_221024_88}") or IsInDebugMsg("#{BJJH_221024_70") then
            PushColorMsg("排除玩家：" .. tmp.name)
            table.insert(m_data.filter, tmp.name)
          end
          break
        end
      end
    end
    if IsInDebugMsg("#{BJJH_221024_87}") then
      break
    end
    if GetTickCount() - oldTick > m_param.maxTick then
      LogMsg("斟酒:已执行指定时长")
      break
    end
    Sleep(500)
    DebugStr("斟酒中")
  end
  DeleteDebugMsg("#{BJJH_221024_12}")
  DeleteDebugMsg("#{BJJH_221024_14}")
  DeleteDebugMsg("#{BJJH_221024_18}")
  DeleteDebugMsg("#{BJJH_221024_19}")
  DeleteDebugMsg("#{BJJH_221024_29}")
  DeleteDebugMsg("#{BJJH_221024_30}")
  for i = 1, 10 do
    GoToSceneNPC(npc.name, npc.x, npc.y, LUOYANG_ID)
    DialogOptionClicked("领取饮酒奖励", 1, 1000)
    if IsInDebugMsg("#{BJJH_221024_12}") or IsInDebugMsg("#{BJJH_221024_14}") then
      break
    end
  end
  for i = 1, 10 do
    GoToSceneNPC(npc.name, npc.x, npc.y, LUOYANG_ID)
    DialogOptionClicked("领取斟酒奖励")
    if IsInDebugMsg("#{BJJH_221024_18}") or IsInDebugMsg("#{BJJH_221024_19}") then
      break
    end
  end
  for i = 1, 10 do
    GoToSceneNPC(npc.name, npc.x, npc.y, LUOYANG_ID)
    DialogOptionClicked("领取上周斟酒达成奖励", 1, 1000)
    DialogOptionClicked("领取斟酒达成奖励", 1, 1000)
    if IsInDebugMsg("#{BJJH_221024_29}") or IsInDebugMsg("#{BJJH_221024_30}") then
      break
    end
  end
end

function _SMain(...)
  BJJJH_Action()
end

_SMain()
ScriptOnStop(m_script_name)
