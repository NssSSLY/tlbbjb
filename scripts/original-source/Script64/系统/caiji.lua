-- 反编译自 dfz64.dll 内嵌字节码 0049878b（unluac 2025-12-23；仅供分析）
function CaiJiCheckTool(aToolName)
  if not aToolName then
    return
  end
  local buyName = aToolName
  if string.find(buyName, "太公钓", nil, true) then
    buyName = "钓鱼竿"
  end
  local tItem = Bag:SearchItemName(aToolName)
  if 0 == #tItem then
    local strName = GetLuaValue("local ActionIndex = EnumAction(0, 'equip') return ActionIndex:GetName() ", "s")
    if "" == strName or not string.find(aToolName, strName, nil, true) then
      PushDebugMessage("生活工具：尝试锦囊取出")
      if TempBank2Bag(aToolName, 0) == false then
        PushDebugMessage("生活工具：没有采集工具前往仓库取出")
        local tBankItme = Bank_EnumItem()
        tItem = Bag:SearchItemName(aToolName, tBankItme)
        if #tItem > 0 then
          Bank_GetItem(aToolName, 1)
        end
      end
      Sleep(500)
      tItem = Bag:SearchItemName(aToolName)
      if 0 == #tItem then
        PushDebugMessage("生活工具：没有采集工具前往购买")
        Bank_GetMoney(200)
        for i = 1, 10 do
          GoToSceneNPC("芮福祥", 347, 284, LUOYANG_ID)
          QuestFrameOptionClicked_Item("买卖杂货", 1, 800)
          Shop_BuyItem(buyName, 1)
          tItem = Bag:SearchItemName(aToolName)
          if #tItem > 0 then
            break
          end
        end
      end
    end
  end
end

function CaiJiCheckActionEnergy(aParam)
  if aParam.jlbz.cmpmin > 0 then
    local nEnergy = Player:GetDataInt("ENERGY")
    if nEnergy <= 0 then
      Sleep(3000)
      nEnergy = Player:GetDataInt("ENERGY")
    end
    if nEnergy <= aParam.jlbz.cmpmin then
      return false
    end
  end
  return true
end

function CaiJiEnumObj(aParam)
  local tAll, tObj, tPlayer = {}, {}, {}
  if aParam.itemclass and aParam.itemclass ~= "" then
    tObj = Enum2XByClass(aParam.itemclass)
  else
    tAll = Enum2XByClass("矿地 玩家")
    tObj = ObjFilterByStrClass(tAll, "矿地")
    tPlayer = ObjFilterByStrClass(tAll, "玩家")
  end
  local tActionPlayer = {}
  for i = 1, #tPlayer do
    local tmp = tPlayer[i]
    if 8 == tmp.state and tmp.name ~= g_self.name then
      table.insert(tActionPlayer, tmp)
    end
  end
  tObj = ObjFilterByName(tObj, aParam.item, 3)
  tObj = ObjTickFilter(tObj, aParam.filter, 60000)
  local tTar = tObj
  if #tActionPlayer > 0 then
    if 4 == g_self.menpai and aParam.ylxs then
      DebugStr("采集：有他人正在采集,您已设置月落西山,不进行id过滤", 3)
    else
      local tFilter = {}
      for i = 1, #tActionPlayer do
        if #tObj > 0 then
          GetAllPosDist(tObj, tActionPlayer[i], "otherdist")
          BubbleSort(tObj, "otherdist", 1)
          if tObj[1].dst > 3 and tObj[1].otherdist < 2.5 then
            PushColorMsg("采集：忽略id:%d,他人正在采集", tObj[1].id)
            table.insert(tFilter, tObj[1])
          end
        end
      end
      tTar = TableDeleteTable(tObj, tFilter, "id")
    end
  end
  return tTar
end

function CaiJi2_EnumObj(aParam)
  local tObj = {}
  if aParam.itemclass and aParam.itemclass ~= "" then
    tObj = Enum2XByClass(aParam.itemclass)
  else
    tObj = Enum2XByClass("宝箱")
  end
  tObj = ObjFilterByName(tObj, aParam.item, 3)
  local tItem = {}
  for i = 1, #tObj do
    local tmp = tObj[i]
    if tmp.model ~= 6729 and tmp.model ~= 6730 and tmp.model ~= 6731 then
      table.insert(tItem, tmp)
    end
  end
  return tItem
end

function CaiJiAnQuanDianWait(aParam)
  while true do
    DebugStr("采集：精力不足,等待精力达到%d继续.", 1, aParam.jlbz.cmpmax)
    local nEnergy = Player:GetDataInt("ENERGY")
    if nEnergy <= 0 then
      Sleep(3000)
      nEnergy = Player:GetDataInt("ENERGY")
    end
    if nEnergy <= aParam.jlbz.cmpmax then
      GoSafeScene(aParam.safepos.sceneName, aParam.safepos.x, aParam.safepos.y, aParam.syzq)
      Dismount()
      if 7 == g_self.menpai and aParam.jctq then
        if -1 == Player:GetBuff("隐身") then
          Dismount()
          Skill:UseName("金蝉脱壳", 1500)
        end
      elseif -1 == Player:GetBuff("打坐：") then
        Skill:UseName("初级隐遁", 1500)
        Skill:UseName("打坐", 1500)
      end
    else
      break
    end
    Sleep(500)
  end
  local pos = {x = 0, y = 0}
  MoveKaTuSetLastPos(pos)
  MoveKaTuSetSDPos(pos)
end

function CaiJiCheckState(aParam)
  if IsMount() == false then
    CDG:checkHP(true)
    CDG:checkMP(true)
    CDG:checkMP(true)
  end
  if GetTickCount() - aParam.checktick > 15000 then
    Pet:Relax(100)
    local nSpaceNum = Bag:GetSpaceNum(1)
    if 0 == nSpaceNum then
      Bag_DeleteBagItem()
      if aParam.bagfullover then
        nSpaceNum = Bag:GetSpaceNum(1)
        if 0 == nSpaceNum then
          PushColorMsg("采集:材料包已满,且无可销毁的物品,停止运行！可设置和交易或存仓循环运行")
          aParam.over = true
        else
          PushDebugMessage("采集：材料包满,已经清理完毕！")
        end
      end
    elseif nSpaceNum < 4 then
      Bag_DeleteBagItem()
    end
    if aParam.hcjx and Player:GetHPP() < 20 and Player:GetHPP() > 0 then
      PushColorMsg("采集：低血回城加血...")
      XiaoChangHuiXue(100, true)
    end
    if not CaiJiCheckActionEnergy(aParam) then
      if 1 == aParam.jlbz.action then
        PushColorMsg("采集：精力不足,安全点休息")
        CaiJiAnQuanDianWait(aParam)
      elseif 2 == aParam.jlbz.action then
        PushColorMsg("采集:精力不足,停止！")
        aParam.over = true
      else
        PushColorMsg("采集：精力不足!")
      end
    end
    if aParam.exp_over then
      local nLevel, bUp = GetLifeInfo(7)
      if bUp then
        LogMsg("采矿：熟练度已满可升级!")
        aParam.over = true
      end
    end
    if 7 == g_self.menpai and aParam.jctq and -1 == Player:GetBuff("隐身") then
      Dismount()
      Skill:UseName("金蝉脱壳", 1500)
    end
    aParam.checktick = GetTickCount()
  end
end

function CaiJiFindPickObj(aParam)
  if aParam.cb then
    aParam.over = aParam.cb()
  end
  local tObj = CaiJiEnumObj(aParam)
  local lastTid = -1
  local bfindObj = false
  while #tObj > 0 do
    if aParam.cb then
      aParam.over = aParam.cb()
    end
    if not (not aParam.over and CaiJiCheckActionEnergy(aParam)) then
      break
    end
    bfindObj = true
    BubbleByDst(tObj)
    local tmp = tObj[1]
    if tmp.dst >= 2 then
      RunTo(tmp.x, tmp.y, 0, 200)
    end
    local nowScene = -1
    if tmp.dst >= 3 then
      local tick_out = GetTickCount()
      
      local function _fun(aX, aY, aScene)
        DebugStr("采集:移动到%s,%s 采集id:%d", 3, math.floor(aX), math.floor(aY), tmp.id)
        if GetTickCount() - tick_out > 13000 then
          PushColorMsg("采集:移动到%s,%s超时", math.floor(aX), math.floor(aY))
          return false
        end
        if not FindObjByTID(tmp.id) then
          PushDebugMessage("采集：目标id:%d或已被采集！", tmp.id)
          return false
        end
        if IsKVKSceneUnCity(aScene) and GetDist(aX, aY) < 5 and 2 ~= Player:GetState() then
          PushColorMsg("采集:易卡坐标")
          RunTo(aX, aY, 0, 1000)
          PlayerStateTimeOut(2, 3)
          return false
        end
        return true
      end
      
      nowScene = GetSceneID()
      MoveTo(tmp.x, tmp.y, nowScene, 2.49, aParam.syzq, nil, _fun)
      local tid = tmp.id
      tmp = FindObjByTID(tid)
      if nil == tmp then
        aParam.filter = ObjTickPush(aParam.filter, tid)
      end
    end
    if tmp then
      if tmp.dst >= 3 then
        if -1 ~= nowScene and IsKVKSceneUnCity(nowScene) then
          if tmp.dst >= 4 then
            aParam.filter = ObjTickPush(aParam.filter, tmp.id)
          end
        else
          aParam.filter = ObjTickPush(aParam.filter, tmp.id)
        end
      end
      for i = 1, 20 do
        if Dismount() then
          break
        end
      end
      if lastTid ~= tmp.id then
        if 4 == g_self.menpai and aParam.ylxs then
          local tMount = Enum2XByClass("玩家 怪物", {0, 5})
          tMount = ObjFilterByName(tMount, g_self.name, 4)
          if #tMount > 0 then
            Skill:UseName("月落西山", 200)
          end
        end
        if aParam.cjyd and -1 == Player:GetBuff("隐身") then
          local tMount = Enum2XByClass("怪物", {0, -1})
          if #tMount > 0 then
            Skill:UseName("初级隐遁", 100)
          end
        end
      end
      
      local function _state_cb()
        local bOk = GetLuaValue("if IsWindowShow('LootPacket') then setmetatable(_G, {__index =LootPacket_Env});LootPacket_Collect_Clicked();LootPacket_Button_Close(); return 1 end; return 0 ", "b")
        if bOk then
          Sleep(50)
          return false
        end
        local _find = FindObjByTID(tmp.id)
        if nil == _find then
          PushDebugMessage("采集：目标已被采集！")
          if 8 == Player:GetState() then
            local pos = Player:GetPos()
            AutoRunToTarget(pos.x + 1, pos.y, -1, false)
          end
          return false
        end
        return true
      end
      
      DeleteDebugMsg("#{ResultText_12}")
      for i = 1, 2 do
        OpenPackage(tmp.id)
        local bWait = PlayerStateTimeOut(8, 20, _state_cb)
        _state_cb()
        if bWait then
          aParam.filter = ObjTickPush(aParam.filter, tmp.id)
        end
        if IsInDebugMsg("#{ResultText_12}") then
          RunTo(tmp.x, tmp.y, 0, 600)
          PlayerStateTimeOut(2, 2)
        else
          break
        end
      end
      DebugStr("采集：目标id:%d x:%s y:%s", 2, tmp.id, math.floor(tmp.x), math.floor(tmp.y))
      if IsInDebugMsg("#{ResultText_12}") then
        PushColorMsg("采集：距离过远,过滤掉" .. tmp.id)
        aParam.filter = ObjTickPush(aParam.filter, tmp.id)
      end
      lastTid = tmp.id
    end
    Sleep(10)
    tObj = CaiJiEnumObj(aParam)
  end
  CaiJiCheckState(aParam)
  if aParam.syzq and IsMount() == false and 8 ~= Player:GetState() then
    UseMount()
  end
  return bfindObj
end

function CaiJi2_FindPickObj(aParam)
  if aParam.cb then
    aParam.over = aParam.cb()
  end
  local tObj = CaiJi2_EnumObj(aParam)
  local lastTid = -1
  local bfindObj = false
  while #tObj > 0 do
    if aParam.cb then
      aParam.over = aParam.cb()
      if aParam.over then
        break
      end
    end
    bfindObj = true
    BubbleByDst(tObj)
    local tmp = tObj[1]
    if tmp.dst >= 2 then
      RunTo(tmp.x, tmp.y, 0, 200)
    end
    if tmp.dst >= 3 then
      local tick_out = GetTickCount()
      
      local function _fun(aX, aY, aScene)
        DebugStr("采集:移动到%s,%s 采集id:%d", 3, math.floor(aX), math.floor(aY), tmp.id)
        if GetTickCount() - tick_out > 13000 then
          PushColorMsg("采集:移动到%s,%s超时", math.floor(aX), math.floor(aY))
          return false
        end
        if not FindObjByTID(tmp.id) then
          PushDebugMessage("采集：目标id:%d或已被采集！", tmp.id)
          return false
        end
        return true
      end
      
      MoveTo(tmp.x, tmp.y, GetSceneID(), 2.49, aParam.syzq, nil, _fun)
      local tid = tmp.id
      tmp = FindObjByTID(tid)
      if nil == tmp then
        aParam.filter = ObjTickPush(aParam.filter, tid)
      end
    end
    if tmp then
      if tmp.dst >= 3 then
        aParam.filter = ObjTickPush(aParam.filter, tmp.id)
      end
      for i = 1, 20 do
        if Dismount() then
          break
        end
      end
      if lastTid ~= tmp.id then
        if 4 == g_self.menpai and aParam.ylxs then
          local tMount = Enum2XByClass("玩家 怪物", {0, 5})
          tMount = ObjFilterByName(tMount, g_self.name, 4)
          if #tMount > 0 then
            Skill:UseName("月落西山", 200)
          end
        end
        if aParam.cjyd and -1 == Player:GetBuff("隐身") then
          local tMount = Enum2XByClass("怪物", {0, -1})
          if #tMount > 0 then
            Skill:UseName("初级隐遁", 100)
          end
        end
      end
      
      local function _state_cb()
        local _find = FindObjByTID(tmp.id)
        if nil == _find then
          PushDebugMessage("采集：目标已被采集！")
          return false
        end
        return true
      end
      
      DeleteDebugMsg("#{ResultText_12}")
      for i = 1, 2 do
        if tmp.name == "紫微香兰" then
          Skill.CUseSkillByID(4814, tmp.id, -1, -1)
        elseif tmp.name == "紫微银堇" then
          Skill.CUseSkillByID(4815, tmp.id, -1, -1)
        elseif tmp.name == "紫微凤尾" then
          Skill.CUseSkillByID(4816, tmp.id, -1, -1)
        else
          Skill.CUseSkillByID(3, tmp.id, -1, -1)
        end
        PlayerStateTimeOut(2, 3, _state_cb)
        local bWait = PlayerStateTimeOut(5, 20, _state_cb)
        _state_cb()
        if bWait then
          aParam.filter = ObjTickPush(aParam.filter, tmp.id)
        end
        if IsInDebugMsg("#{ResultText_12}") then
          RunTo(tmp.x, tmp.y, 0, 600)
          PlayerStateTimeOut(2, 2)
        else
          break
        end
      end
      DebugStr("采集：目标id:%d x:%s y:%s", 2, tmp.id, math.floor(tmp.x), math.floor(tmp.y))
      if IsInDebugMsg("#{ResultText_12}") then
        PushColorMsg("采集：距离过远,过滤掉" .. tmp.id)
        aParam.filter = ObjTickPush(aParam.filter, tmp.id)
      end
      lastTid = tmp.id
    end
    Sleep(10)
    tObj = CaiJi2_EnumObj(aParam)
  end
  return bfindObj
end

function CaiJiOnAction(aParam)
  local function _cj_move_cb(aX, aY, aScene)
    local bfindObj = false
    
    if 2 == aParam.cj_type then
      bfindObj = CaiJi2_FindPickObj(aParam)
    else
      bfindObj = CaiJiFindPickObj(aParam)
    end
    if aParam.over then
      return false
    else
    end
    if bfindObj or 2 ~= Player:GetState() then
      AutoRunToTarget(aX, aY, aScene, true)
      if bfindObj then
        MoveKaTuSetLastPos(Player:GetPos())
      end
      Sleep(100)
    end
    return MoveCallBack_Default(aX, aY, aScene)
  end
  
  local startPosIndex = -1
  local startScene = GetCurrentSceneName()
  startScene = string.gsub(startScene, "1线", "")
  startScene = string.gsub(startScene, "2线", "")
  if not FindTableFieldValue(aParam.scene, "name", startScene) then
    startScene = ""
  end
  if "" ~= startScene then
    for i = 1, #aParam.scene do
      if aParam.scene[i].name == startScene then
        local nCmp = 9999
        local myPos = Player:GetPos()
        for j = 1, #aParam.scene[i].pos do
          local pos = aParam.scene[i].pos[j]
          local nDist = GetDist(myPos.x, myPos.y, pos.x, pos.y)
          if nCmp > nDist then
            startPosIndex = j
            nCmp = nDist
          end
        end
        break
      end
    end
  end
  while true do
    for i = 1, #aParam.scene do
      local sceneName = aParam.scene[i].name
      local hasID = aParam.scene[i].id
      local scenePos = aParam.scene[i].pos
      if "" == startScene or startScene == sceneName then
        startScene = ""
        local sceneID = hasID or GetSceneIDByName(sceneName)
        if nil == sceneName or "" == sceneName then
          sceneName = GetSceneNameByID(sceneID)
        end
        if sceneID >= 0 then
          local nPos = #scenePos
          for i = 1, nPos do
            if i >= startPosIndex or i == nPos then
              startPosIndex = -1
              local pos = scenePos[i]
              if 1 == nPos then
                DebugStr("采集：前往[%s,%s,%s],共%d个坐标,剩余%d个", 2, sceneName, pos.x, pos.y, nPos, nPos - i)
              else
                PushDebugMessage("采集：前往[%s,%s,%s],共%d个坐标,剩余%d个", sceneName, pos.x, pos.y, nPos, nPos - i)
              end
              local bMount = aParam.syzq
              if not bMount and GetSceneID() ~= sceneID then
                bMount = true
              end
              MoveTo(pos.x, pos.y, sceneID, 3, bMount, nil, _cj_move_cb)
              if 2 == aParam.cj_type then
                CaiJi2_FindPickObj(aParam)
              else
                CaiJiFindPickObj(aParam)
              end
              if aParam.over then
                break
              end
            end
          end
        else
          PushColorMsg("采集:地图 %s 获取id失败", sceneName)
        end
      end
      if aParam.over then
        break
      end
    end
    if aParam.over then
      break
    end
    Sleep(50)
    DebugStr("采集：地图循环采集中.")
  end
end

function BeginCaiji(aCaiJiItem, aCaiJiSceneNameID, aCaiJiPos, aCaiJiCB, aItemClass, aSkillType)
  local param = {
    over = false,
    bagfullover = false,
    syzq = true,
    ylxs = false,
    jctq = false,
    cjyd = true,
    hcjx = false,
    exp_over = false,
    checktick = -1,
    jlbz = {
      cmpmin = 0,
      cmpmax = 250,
      action = 0
    },
    safepos = {
      sceneName = "",
      x = -1,
      y = -1
    },
    filter = {},
    item = aCaiJiItem,
    scene = {},
    cb = aCaiJiCB,
    itemclass = "",
    cj_type = 1
  }
  if aItemClass then
    param.itemclass = aItemClass
  end
  if aSkillType then
    param.cj_type = aSkillType
  end
  if type(aCaiJiSceneNameID) == "string" then
    local scene = {
      id = nil,
      name = aCaiJiSceneNameID,
      pos = aCaiJiPos
    }
    table.insert(param.scene, scene)
  else
    local scene = {
      id = aCaiJiSceneNameID,
      name = "",
      pos = aCaiJiPos
    }
    table.insert(param.scene, scene)
  end
  CaiJiOnAction(param)
end
