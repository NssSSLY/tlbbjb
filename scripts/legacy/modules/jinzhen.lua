-- 金针渡劫, written from the reference rules (原脚本源码/Script64/任务/金针渡劫.lua). 峨嵋 only. The mission table below is the reference's; quest_book.lua holds the helpers.
-- docs/DAILY_TASKS_HANDOFF.md names the differences.
LoadScript('quest_book')
Jinzhen={}
local SCENES={['西湖']=30}
local function book(_ENV)
    local function ZhuXianAttack(m) m.attackMode='打死换怪';mission_attack_mode_1(m) end
    local function ZhuXianComplete(m) mission_complete_talk_npc(m) end
local MissionTable = {
  function()
    local apt = {
      x = 43,
      y = 108,
      sceneID = 15,
      name = "韩映雪"
    }
    local comp = {
      x = 229,
      y = 248,
      sceneID = 2,
      name = "王韶"
    }
    local misName = "金针渡劫-重攻轻守"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 229,
      y = 248,
      sceneID = 2,
      name = "王韶"
    }
    local comp = apt
    local misName = "金针渡劫-子午针灸经"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = {
          {x = 265, y = 252}
        },
        sceneName = "西湖",
        targetName = "龙井水贼",
        is_pick = true,
        pick_item = "子午针灸经残页",
        call_back_attack = function()
          DebugStr("金针渡劫-子午针灸经:正在执行中", 2)
          local nComplete, nIndex = GetMissionVariableByName_Item("金针渡劫-子午针灸经", 0)
          if 1 == nComplete or -1 == nIndex then
            return true
          end
          return false
        end
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 229,
      y = 248,
      sceneID = 2,
      name = "王韶"
    }
    local comp = {
      x = 216,
      y = 204,
      sceneID = 1,
      name = "庞安时"
    }
    local misName = "金针渡劫-三人同行"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 229,
      y = 248,
      sceneID = 2,
      name = "王韶"
    }
    local comp = {
      x = 216,
      y = 204,
      sceneID = 1,
      name = "庞安时"
    }
    local misName = "金针渡劫-回马枪"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function()
        if 124 == GetSceneID() then
          local fubenSceneID = 124
          CDG.jgyc = false
          CDG.targetName = ""
          CDG.sceneID = fubenSceneID
          CDG.sceneName = "集市"
          CDG.attackMode = "优先近怪"
          CDG.pickup = false
          CDG.overMapErr = true
          CDG.die.out = true
          CDG.posRadius = 15
          CDG.tragetSelect = true
          CDG.die.maxCount = 0
          CDG.savebank = false
          CDG.pos = {
            {x = 32, y = 38},
            {x = 19, y = 38},
            {x = 22, y = 23},
            {x = 34, y = 23}
          }
          CDG.posIdx = GetNearestPoint(CDG.pos)
          CDG:SetTimeOut(100)
          
          local function CDG_loop_callback(...)
            DebugStr("金针渡劫：副本中.")
            if GetSceneID() ~= fubenSceneID then
              return true
            end
            Player:TeamFollow(false, 300)
            local nComplete = GetMissionVariableByName_Item("金针渡劫-回马枪", 0)
            if 0 ~= nComplete then
              PushColorMsg("金针渡劫:任务完成")
              return true
            end
            return false
          end
          
          local function sf_move_cb_in_fb(fX, fY, nScene)
            if GetSceneID() ~= fubenSceneID then
              return false
            end
            return true
          end
          
          CDG.callfun = CDG_loop_callback
          CDG.callfun_move = sf_move_cb_in_fb
          CDG.clearBag = false
          CDG:OnStart()
        else
          GoToSceneNPC("庞安时", 216, 204, 1)
          DialogOptionClicked("送我去集市", 1, 1000)
        end
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 216,
      y = 204,
      sceneID = 1,
      name = "庞安时"
    }
    local comp = {
      x = 229,
      y = 248,
      sceneID = 2,
      name = "王韶"
    }
    local misName = "金针渡劫-一代奇才"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 229,
      y = 248,
      sceneID = 2,
      name = "王韶"
    }
    local comp = {
      x = 229,
      y = 248,
      sceneID = 2,
      name = "王韶"
    }
    local misName = "金针渡劫-运用自如"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = function(...)
        if Player:GetMoney(1) < 50000 then
          Bank_GetMoney(50000)
        else
          ZhuXianComplete(...)
        end
      end
    }
    return mission
  end
}

    return MissionTable
end
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end
function Jinzhen.run()
    local api=Shaoshi.newApi();local cfg=TaskConfig or {}
    local minutes=int(tonumber(cfg.short_minutes or 115),1,115,'总时限')
    if math.floor(api.school())~=4 then error('金针渡劫：只有峨嵋派可以做',0) end
    local Q=QuestBook.new(api,{label='金针渡劫',minutes=minutes,scenes=SCENES})
    local E=Q.env
    local book_=book(E)
    local def={name='金针渡劫',mission='金针渡劫',map='',npc={name='',x=0,y=0,scene=0},bosses={}}
    function def.inside() return false end
    -- The last hand-in charges 5 gold.
    local function gate(mis)
        if mis.name=='金针渡劫-运用自如' and cfg.allow_spend~=true then error('金针渡劫：最后一步要花钱，未打开“允许支付”，已停止',0) end
    end
    local function body()
        api.validate(def,cfg)
        local extra=0
        while true do
            local more=api.resumable(function()
                Q.check()
                if not Q.act(book_,gate) and not Q.commit(book_,gate) and not Q.accept(book_) then
                    if extra>2 then return false end
                    extra=extra+1
                    E.GoToSceneNPC('韩映雪',43,108,15)
                    E.DialogOptionClicked('金针渡劫-重攻轻守',1,700);E.QuestFrameAcceptClicked(500);CloseAllWindow()
                end
                E.Sleep(100)
                return true
            end)
            if more==false then break end
        end
        if Q.handed==0 then return {status='already_done',message='金针渡劫：现在没有可做的任务'} end
        return {status='done',message='金针渡劫交了 '..Q.handed..' 个，已没有可做的任务'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..Q.phase..'；已交 '..Q.handed..' 个]',0) end
    assert(stopped,'金针渡劫停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
