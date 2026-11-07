-- 反编译自 dfz64.dll 内嵌字节码 00478334（unluac 2025-12-23；仅供分析）
local m_script_name = "购买赠点物品"
ScriptOnStart(m_script_name, false, false)
g_config.gmzdwp = {}
g_config.gmzdwp.item = Text2Table(ReadConfigText("ZH", "bjk116"), " ", "text")

function _SMain(...)
  ClearBag()
  local ZengDianItem = {
    {
      item = " 坏掉的刀柄 坏掉的枪杆 坏掉的剑鞘 坏掉的双棍 坏掉的扇骨 坏掉的环片 坏掉的天眼 坏掉的地心 坏掉的玄丝 坏掉的黄骨 坏掉的冰肌 坏掉的雪魄 坏掉的寒云 草皮革 草皮毛 新鲜肉 奇特的味腺 绿色液体 ",
      option = "一级材料",
      nPrice = 2
    },
    {
      item = " 残缺的刀柄 残缺的枪杆 残缺的剑鞘 残缺的双棍 残缺的扇骨 残缺的环片 残缺的天眼 残缺的地心 残缺的玄丝 残缺的黄骨 残缺的冰肌 残缺的雪魄 残缺的寒云 轻皮革 轻皮毛 细嫩肉 怪味肉 红色液体 ",
      option = "二级材料",
      nPrice = 2
    },
    {
      item = " 破损的刀柄 破损的枪杆 破损的剑鞘 破损的双棍 破损的扇骨 破损的环片 破损的天眼 破损的地心 破损的玄丝 破损的黄骨 破损的冰肌 破损的雪魄 破损的寒云 小皮革 小皮毛 前肘肉 残缺的内丹 怪物的血液 ",
      option = "三级材料",
      nPrice = 2
    },
    {
      item = " 破旧的刀柄 破旧的枪杆 破旧的剑鞘 破旧的双棍 破旧的扇骨 破旧的环片 破旧的天眼 破旧的地心 破旧的玄丝 破旧的黄骨 破旧的冰肌 破旧的雪魄 破旧的寒云 中皮革 中皮毛 后肘肉 完整的内丹 怪物的毛发 ",
      option = "四级材料",
      nPrice = 3
    },
    {
      item = " 完好的刀柄 完好的枪杆 完好的剑鞘 完好的双棍 完好的扇骨 完好的环片 完好的天眼 完好的地心 完好的玄丝 完好的黄骨 完好的冰肌 完好的雪魄 完好的寒云 大皮革 大皮毛 前腿肉 发光的内丹 奇特的爪子 ",
      option = "五级材料",
      nPrice = 3
    },
    {
      item = " 普通的刀柄 普通的枪杆 普通的剑鞘 普通的双棍 普通的扇骨 普通的环片 普通的天眼 普通的地心 普通的玄丝 普通的黄骨 普通的冰肌 普通的雪魄 普通的寒云 真皮革 真皮毛 后腿肉 完美的内丹 黑暗牙齿 ",
      option = "六级材料",
      nPrice = 3
    },
    {
      item = " 发光的刀柄 发光的枪杆 发光的剑鞘 发光的双棍 发光的扇骨 发光的环片 发光的天眼 发光的地心 发光的玄丝 发光的黄骨 发光的冰肌 发光的雪魄 发光的寒云 厚皮革 厚皮毛 侧股肉 闪亮的内丹 野蛮之血 ",
      option = "七级材料",
      nPrice = 4
    },
    {
      item = " 完美的刀柄 完美的枪杆 完美的剑鞘 完美的双棍 完美的扇骨 完美的环片 完美的天眼 完美的地心 完美的玄丝 完美的黄骨 完美的冰肌 完美的雪魄 完美的寒云 重皮革 重皮毛 里脊肉 无瑕的内丹 灵丹碎片 ",
      option = "八级材料",
      nPrice = 4
    },
    {
      item = " 闪亮的刀柄 闪亮的枪杆 闪亮的剑鞘 闪亮的双棍 闪亮的扇骨 闪亮的环片 闪亮的天眼 闪亮的地心 闪亮的玄丝 闪亮的黄骨 闪亮的冰肌 闪亮的雪魄 闪亮的寒云 鳞皮革 白条肉 兽丹 灵丹 ",
      option = "九级材料",
      nPrice = 6
    },
    {
      item = " 七彩的刀柄 七彩的枪杆 七彩的剑鞘 七彩的双棍 七彩的扇骨 七彩的环片 七彩的天眼 七彩的地心 七彩的玄丝 七彩的黄骨 七彩的冰肌 七彩的雪魄 七彩的寒云 鳞皮毛 肥肉 妖丹 异丹 ",
      option = "十级材料",
      nPrice = 6
    }
  }
  local tItem = {}
  for i = 1, #g_config.gmzdwp.item do
    local tmp = g_config.gmzdwp.item[i]
    table.insert(tItem, {
      name = tmp.text,
      buy_count = 3000
    })
  end
  local tBuy = {}
  for i = 1, #tItem do
    local tmp = tItem[i]
    tmp.old_count = Bag:GetItemCount(tmp.name, nil, nil, Bag:EnumCailiaoItem())
    for j = 1, #ZengDianItem do
      local shop = ZengDianItem[j]
      if string.find(shop.item, " " .. tmp.name .. " ", nil, true) then
        tmp.level = j
        tmp.option = shop.option
        tmp.price = shop.nPrice
        table.insert(tBuy, tmp)
        break
      end
    end
  end
  if 0 == #tBuy then
    PushColorMsg(m_script_name .. ":您设置的赠点商品名称有误！")
    return
  end
  CloseWindow("Shop")
  
  local function _BuyZendDian(aItem, aCount)
    GoToSceneNPC("孙进宝", 65, 40, 224)
    Sleep(500)
    QuestFrameOptionClicked_Item("赠点商店", 1, 700)
    QuestFrameOptionClicked_Item(aItem.option .. " ", 1, 700)
    local nSpace = Bag:GetSpaceNum(1)
    local nZengD = Player:GetDataInt("ZENGDIAN")
    local buyNum = aCount
    local maxCount = (nSpace - 2) * 40
    if buyNum > maxCount then
      buyNum = maxCount
    end
    local nNeedZengDian = buyNum * aItem.price
    if nZengD < nNeedZengDian then
      buyNum = math.floor(nZengD / aItem.price)
    end
    if buyNum > 1200 then
      buyNum = 1200
    end
    if buyNum > 0 then
      Shop_BuyItem(aItem.name, buyNum)
      return true
    end
    return false
  end
  
  while true do
    local bBuy = false
    for i = 1, #tBuy do
      local buy = tBuy[i]
      local buyCount = Bag:GetItemCount(buy.name, nil, nil, Bag:EnumCailiaoItem())
      buyCount = buyCount - buy.old_count
      if buyCount < buy.buy_count then
        bBuy = true
        if _BuyZendDian(buy, buy.buy_count - buyCount) == false then
          break
        end
      end
    end
    if false == bBuy then
      PushDebugMessage(m_script_name .. ":购买完成")
      break
    end
    Sleep(500)
    local nSpace = Bag:GetSpaceNum(1)
    local nZengD = Player:GetDataInt("ZENGDIAN")
    if nSpace <= 2 then
      PushColorMsg(m_script_name .. ":材料栏空格不足 2 ")
      break
    end
    if nZengD <= 6 then
      PushColorMsg(m_script_name .. ":赠点不足！")
      break
    end
    DebugStr(m_script_name)
  end
end

_SMain()
ScriptOnStop(m_script_name)
