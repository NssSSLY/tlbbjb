-- 反编译自 dfz64.dll 内嵌字节码 00470b01（unluac 2025-12-23；仅供分析）
local m_script_name = "购买红利半价商品"
ScriptOnStart(m_script_name, false, false)
g_config.gmbjhlsp = {}
g_config.gmbjhlsp.buy = ReadConfigText("ZH", "bjk105")

function _SMain(...)
  ClearBag()
  DeleteDebugMsg("#{LJSD_180312_05}")
  DeleteDebugMsg("对不起，您的红利数量不足，完成每周的工资任务可以获得红利。")
  
  local function ybsd_buyItem(aPage, aChildPage, aStrItem)
    DebugStr("购买宝石：" .. aStrItem, 2)
    local strText = fmt("setmetatable(_G, {__index = YuanbaoShop_Env});YuanbaoShop_ChangeTabIndex(%d);YuanbaoShop_UpdateList(%d)", aPage, aChildPage)
    GetLuaValue(strText)
    Sleep(1200)
    strText = "            local nBuy = 0\n            for i = 1, 36 do\n                local idx = i - 1\n                local theAction = EnumAction(idx, \"boothitem\")\n                if theAction:GetID() ~= 0 then\n                    local szName = theAction:GetName()\n                    if string.find(\"%s\", \" \" .. szName .. \" \", nil, true) then\n                        local nPrice = NpcShop:EnumItemPrice(idx)\n                        if nPrice == 210 or nPrice == 220 or nPrice == 270 or nPrice == 860 then\n                            PushDebugMessage(\"物品序号:\" .. idx)\n                            NpcShop:BulkBuyItem(idx, 1, 0)\n                            nBuy = 1\n                        end\n                    end\n                end\n            end\n            return nBuy\n        "
    strText = fmt(strText, aStrItem)
    local isBuy = GetLuaValue(strText, "b")
    return isBuy
  end
  
  local nTickOut = GetTickCount()
  local strGem = HandleText_AddFuHao(g_config.gmbjhlsp.buy, " ")
  while true do
    ybsd_buyItem(5, 5, strGem)
    Sleep(800)
    if IsInDebugMsg("#{LJSD_180312_05}") or IsInDebugMsg("对不起，您的红利数量不足，完成每周的工资任务可以获得红利。") then
      break
    end
    if GetTickCount() - nTickOut > 65000 then
      PushColorMsg(m_script_name .. ":购买超时")
      break
    end
    Sleep(500)
    DebugStr(m_script_name)
  end
end

_SMain()
ScriptOnStop(m_script_name)
