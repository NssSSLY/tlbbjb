-- 反编译自 dfz64.dll 内嵌字节码 0034751d（unluac 2025-12-23；仅供分析）
ScriptOnStart("名士赠礼", false, false)

local function MSZL_ZengLi(aNpcName, aItemName)
  local strText = fmt("            local bGive = 0\n            local npcName = \"%s\"\n            local itemName = \"%s\"\n            local nYingXiongNum = DataPool:LuaFnGetXingZhen_YingXiongNum()\n            for i = 1, nYingXiongNum do\n                local nYingXiongId = i\n                local strName = DataPool:LuaFnGetXingZhen_YingXiongInfo(nYingXiongId, \"Name\")\n                if strName == npcName then\n                    local nYingXiongLevel = DataPool:LuaFnGetXingZhen_YingXiongHaoganLevel(nYingXiongId)\n                    if nYingXiongLevel < 10000 then -- 好感度\n                        local tabIds = {}\n                        tabIds[1], tabIds[2], tabIds[3], tabIds[4], tabIds[5] = DataPool:LuaFnGetXingZhen_YingXiongInfo(nYingXiongId, \"Interests\")\n                        for i, nInterestsId in pairs(tabIds) do\n                            local strItemName = DataPool:LuaFnGetXingZhen_InterestsInfo(nInterestsId, \"Name\")\n                            if itemName == strItemName then\n                                local nTotalGiveNum = DataPool:LuaFnGetXingZhen_InterestsTotalGiveNum(nInterestsId)\n                                local nMaxLevel = DataPool:LuaFnGetXingZhen_InterestsInfo(nInterestsId, \"MaxLevel\")\n                                if nTotalGiveNum == nMaxLevel * 10 then\n                                else\n                                    Clear_XSCRIPT()\n                                        Set_XSCRIPT_Function_Name(\"OpenXZ3_GiveGift\")\n                                        Set_XSCRIPT_ScriptID(888052)\n                                        Set_XSCRIPT_Parameter(0, nYingXiongId)\n                                        Set_XSCRIPT_Parameter(1, i)\n                                        Set_XSCRIPT_ParamCount(2)\n                                    Send_XSCRIPT()\n                                    bGive = 1\n                                end\n                                break\n                            end\n                        end\n                    end\n                    break\n                end\n            end\n            return bGive\n        ", aNpcName, aItemName)
  local bOpen = GetLuaValue(strText, "b")
  if bOpen then
    Sleep(1000)
    if IsWindowVisible("GiveGift") then
      DeleteDebugMsg("#{XZYX_200309_18}")
      local nCount = Bag:GetItemCount(aItemName)
      if nCount >= 10 then
        local nCnt1 = math.floor(nCount / 10)
        local nCnt2 = nCount % 10
        for i = 1, nCnt1 do
          GetLuaValue("setmetatable(_G, {__index = GiveGift_Env});GiveGift_GiveTenTime()")
          Sleep(50)
          if IsInDebugMsg("#{XZYX_200309_18}") then
            break
          end
        end
        for i = 1, nCnt2 do
          GetLuaValue("setmetatable(_G, {__index = GiveGift_Env});GiveGift_GiveOneTime()")
          Sleep(50)
        end
      else
        for i = 1, nCount do
          GetLuaValue("setmetatable(_G, {__index = GiveGift_Env});GiveGift_GiveOneTime()")
          Sleep(50)
          if IsInDebugMsg("#{XZYX_200309_18}") then
            break
          end
        end
      end
      GetLuaValue("setmetatable(_G, {__index = GiveGift_Env});GiveGift_GiveOneTime()")
    end
  end
  return bOpen
end

local function MSZL_Action(aInfo)
  local tItem = Bag:FindItemInfo(aInfo.itemName, nil, nil, Bag:EnumDaoJuItem())
  if #tItem > 0 then
    if MSZL_ZengLi(aInfo.npcName, aInfo.itemName) == false then
      return false
    end
  else
    return false
  end
  return true
end

function _SMain(...)
  local tZengSong = {
    {
      itemName = "剑谱",
      sceneName = "洛阳",
      npcName = "乔峰",
      mijiName = "大江之势",
      comp = false
    },
    {
      itemName = "女儿红",
      sceneName = "洛阳",
      npcName = "乔峰",
      mijiName = "大江之势",
      comp = false
    },
    {
      itemName = "胭脂盒",
      sceneName = "苏州",
      npcName = "王语嫣",
      mijiName = "汴和抱玉",
      comp = false
    },
    {
      itemName = "湖州笔",
      sceneName = "大理",
      npcName = "阿朱",
      mijiName = "桃源避难",
      comp = false
    },
    {
      itemName = "酸角糕",
      sceneName = "洛阳",
      npcName = "天山童姥",
      mijiName = "攻守兼备",
      comp = false
    },
    {
      itemName = "澄心纸",
      sceneName = "洛阳",
      npcName = "天山童姥",
      mijiName = "攻守兼备",
      comp = false
    },
    {
      itemName = "青玉佩",
      sceneName = "洛阳",
      npcName = "慕容复",
      mijiName = "百二秦关",
      comp = false
    },
    {
      itemName = "满日弓",
      sceneName = "苏州",
      npcName = "李秋水",
      mijiName = "避守孤城",
      comp = false
    },
    {
      itemName = "玄铁矿石",
      sceneName = "苏州",
      npcName = "李秋水",
      mijiName = "避守孤城",
      comp = false
    },
    {
      itemName = "徐夫人匕",
      sceneName = "大理",
      npcName = "梦姑",
      mijiName = "春风江南",
      comp = false
    },
    {
      itemName = "琴箫曲谱",
      sceneName = "洛阳",
      npcName = "慕容复",
      mijiName = "百二秦关",
      comp = false
    },
    {
      itemName = "朱砂印泥",
      sceneName = "洛阳",
      npcName = "无崖子",
      mijiName = "鼎湖龙吟",
      comp = false
    },
    {
      itemName = "义山诗集",
      sceneName = "洛阳",
      npcName = "虚竹",
      mijiName = "诛清君侧",
      comp = false
    },
    {
      itemName = "三段锦紫牙",
      sceneName = "大理",
      npcName = "阿朱",
      mijiName = "桃源避难",
      comp = false
    },
    {
      itemName = "桃花泉奕谱",
      sceneName = "洛阳",
      npcName = "段誉",
      mijiName = "越王破吴",
      comp = false
    }
  }
  local tList = GetConfigList("名士赠礼", "赠礼列表")
  for i = 1, #tList do
    local tmp = tList[i].text
    local arr = SplitString(tmp, "-", "")
    if 4 == #arr then
      table.insert(tZengSong, {
        itemName = arr[1],
        sceneName = arr[2],
        npcName = arr[3],
        mijiName = arr[4],
        comp = false
      })
    end
  end
  local allItemName = ""
  for i = 1, #tZengSong do
    allItemName = allItemName .. tZengSong[i].itemName .. " "
  end
  Bank_GetItem(allItemName)
  TempBank2Bag(allItemName, 2)
  OpenBindItem(5)
  local tick_out = GetTickCount()
  while true do
    local bHave = false
    for i = 1, #tZengSong do
      if tZengSong[i].comp == false and MSZL_Action(tZengSong[i]) then
        bHave = true
        break
      else
        tZengSong[i].comp = true
      end
    end
    Sleep(300)
    if false == OpenBindItem(5) and false == bHave then
      break
    end
    Sleep(300)
    if GetTickCount() - tick_out > 600000 then
      PushColorMsg("名士赠礼：执行超时！")
      break
    end
    DebugStr("名士赠礼")
  end
  CloseWindow("GiveGift")
end

_SMain()
ScriptOnStop("名士赠礼", false)
