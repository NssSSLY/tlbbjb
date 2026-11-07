-- 反编译自 dfz64.dll 内嵌字节码 003461b4（unluac 2025-12-23；仅供分析）
local m_script_name = "名士斋礼物兑换"
ScriptOnStart(m_script_name, false, false)

local function MSZ_GetType(aItemName)
  if "良品礼物兑换券" == aItemName then
    return 1
  elseif "精品礼物兑换券" == aItemName then
    return 2
  elseif "珍品礼物兑换券" == aItemName then
    return 3
  elseif "神品礼物兑换券" == aItemName then
    return 4
  end
  return -1
end

local function MSZ_GetItemType(aItemName)
  local itemTable = {
    {
      type = 1,
      name = "金丝冠",
      itemIndex = 38004165
    },
    {
      type = 1,
      name = "佛跳墙",
      itemIndex = 38004166
    },
    {
      type = 1,
      name = "猴儿酿",
      itemIndex = 38004167
    },
    {
      type = 2,
      name = "妙法拂尘",
      itemIndex = 38004162
    },
    {
      type = 2,
      name = "竹蜻蜓",
      itemIndex = 38004163
    },
    {
      type = 2,
      name = "宝斋刻刀",
      itemIndex = 38004164
    },
    {
      type = 3,
      name = "菩提木佛珠",
      itemIndex = 38004152
    },
    {
      type = 3,
      name = "天青汝窑瓷",
      itemIndex = 38004153
    },
    {
      type = 3,
      name = "上等马驹",
      itemIndex = 38004154
    },
    {
      type = 3,
      name = "十样花罗",
      itemIndex = 38004155
    },
    {
      type = 3,
      name = "山水图",
      itemIndex = 38004156
    },
    {
      type = 3,
      name = "冰素针",
      itemIndex = 38004157
    },
    {
      type = 3,
      name = "焦尾琴",
      itemIndex = 38004158
    },
    {
      type = 3,
      name = "多宝塔碑帖",
      itemIndex = 38004159
    },
    {
      type = 3,
      name = "大红袍",
      itemIndex = 38004160
    },
    {
      type = 3,
      name = "太湖银鱼",
      itemIndex = 38004161
    },
    {
      type = 3,
      name = "青瓷梅子盏",
      itemIndex = 38004618
    },
    {
      type = 3,
      name = "竹雅香炉",
      itemIndex = 38004619
    },
    {
      type = 4,
      name = "女儿红",
      itemIndex = 38004140
    },
    {
      type = 4,
      name = "桃花泉奕谱",
      itemIndex = 38004141
    },
    {
      type = 4,
      name = "义山诗集",
      itemIndex = 38004142
    },
    {
      type = 4,
      name = "琴箫曲谱",
      itemIndex = 38004143
    },
    {
      type = 4,
      name = "满日弓",
      itemIndex = 38004144
    },
    {
      type = 4,
      name = "胭脂盒",
      itemIndex = 38004145
    },
    {
      type = 4,
      name = "徐夫人匕",
      itemIndex = 38004146
    },
    {
      type = 4,
      name = "剑谱",
      itemIndex = 38004147
    },
    {
      type = 4,
      name = "青玉佩",
      itemIndex = 38004148
    },
    {
      type = 4,
      name = "玄铁矿石",
      itemIndex = 38004149
    },
    {
      type = 4,
      name = "湖州笔",
      itemIndex = 38004150
    },
    {
      type = 4,
      name = "三段锦紫牙",
      itemIndex = 38004151
    },
    {
      type = 4,
      name = "澄心纸",
      itemIndex = 38004615
    },
    {
      type = 4,
      name = "酸角糕",
      itemIndex = 38004616
    },
    {
      type = 4,
      name = "朱砂印泥",
      itemIndex = 38004617
    }
  }
  local dhName = aItemName
  local itemFind = GetTableFieldValue(itemTable, "name", {dhName})
  if #itemFind then
    return itemFind[1]
  end
  return nil
end

local function MSZ_DuiHuan(aInfo)
  local tItem = Bag:FindItemInfo(aInfo.quanName)
  if #tItem > 0 then
    GoToScene(207, 53, 2)
    local tNPC = Enum2XByName("沈暝楼", {
      1,
      0,
      0,
      0
    }, nil, nil, 0)
    if #tNPC > 0 then
      local item = MSZ_GetItemType(aInfo.itemName)
      if item then
        local tmp = tItem[1]
        local nHave = Bag:GetItemCount(aInfo.itemName) + Bag:GetItemCount(aInfo.itemName, nil, nil, Bag:EnumTempBagItem())
        local nNeed = aInfo.needCount - (nHave - aInfo.oldCount)
        local curNum = Bag:GetItemCount(tmp.name, nil, nil, Bag:EnumDaoJuItem())
        local nDuiHuan = curNum
        if nNeed < nDuiHuan then
          nDuiHuan = nNeed
        end
        if nDuiHuan > 0 then
          local strText = fmt([[
                                Clear_XSCRIPT()
                                Set_XSCRIPT_Function_Name("BatchExchangeItem")
                                Set_XSCRIPT_ScriptID( 888089 )
                                Set_XSCRIPT_Parameter(0, %d)
                                Set_XSCRIPT_Parameter(1, %d)
                                Set_XSCRIPT_Parameter(2, %d)
                                Set_XSCRIPT_Parameter(3, %d)
                                Set_XSCRIPT_ParamCount(4)
                                Send_XSCRIPT()                    
                                ]], tNPC[1].id, item.type, item.itemIndex, nDuiHuan)
          GetLuaValue(strText)
          Sleep(600)
        else
          return false
        end
      else
        return false
      end
    end
  else
    Bank_GetItem("良品礼物兑换券 精品礼物兑换券 珍品礼物兑换券 神品礼物兑换券")
    Sleep(600)
    tItem = Bag:FindItemInfo(aInfo.quanName)
    if 0 == #tItem then
      TempBank2Bag("良品礼物兑换券 精品礼物兑换券 珍品礼物兑换券 神品礼物兑换券")
      Sleep(600)
      tItem = Bag:FindItemInfo(aInfo.quanName)
      if 0 == #tItem then
        return false
      end
    end
  end
  return true
end

function _SMain(...)
  ClearBag()
  Bag:PackUp(-1)
  local tDuiHuan = {}
  local tList = GetConfigList("名士斋礼物兑换", "兑换列表")
  for i = 1, #tList do
    local tmp = tList[i].text
    local arr = SplitString(tmp, "-", "")
    if 3 == #arr then
      local nCount = tonumber(arr[3])
      local nType = MSZ_GetType(arr[1])
      if nCount and -1 ~= nType then
        table.insert(tDuiHuan, {
          quanType = nType,
          quanName = arr[1],
          itemName = arr[2],
          needCount = nCount,
          oldCount = 0,
          comp = false
        })
      end
    end
  end
  for i = 1, #tDuiHuan do
    local tmp = tDuiHuan[i]
    tDuiHuan[i].oldCount = Bag:GetItemCount(tmp.itemName) + Bag:GetItemCount(tmp.itemName, nil, nil, Bag:EnumTempBagItem())
  end
  local tick_out = GetTickCount()
  while true do
    local bHave = false
    for i = 1, #tDuiHuan do
      local tmp = tDuiHuan[i]
      if tmp.comp == false then
        if false == MSZ_DuiHuan(tmp) then
          tmp.comp = true
        else
          bHave = true
          break
        end
      end
    end
    if false == bHave then
      break
    end
    if GetTickCount() - tick_out > 300000 then
      PushColorMsg(m_script_name .. ":超时！")
      break
    end
    Sleep(500)
    DebugStr(m_script_name)
  end
end

_SMain()
ScriptOnStop(m_script_name)
