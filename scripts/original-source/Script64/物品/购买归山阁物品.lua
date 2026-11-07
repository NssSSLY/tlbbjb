-- 反编译自 dfz64.dll 内嵌字节码 00473eae（unluac 2025-12-23；仅供分析）
local m_script_name = "归山阁购物"
ScriptOnStart(m_script_name, false, false, false)
local m_param = {}
m_param.buymiji = {}
m_param.buyxinjue = {}

local function ShanHai_GetLimit()
  local xj_lp, xj_jp, xj_zp, mj_lp, mj_jp, mj_zp = GetLuaValue([[
            local limit_array = {{0, 0, 0}, {0, 0, 0}, {0, 0, 0}}
            limit_array[1][1], limit_array[1][2], limit_array[1][3], limit_array[2][1], limit_array[2][2], limit_array[2][3], limit_array[3][1], limit_array[3][2], limit_array[3][3] =
                Player:GetData("SHShopLimit")
                return limit_array[1][1], limit_array[1][2], limit_array[1][3], limit_array[2][1], limit_array[2][2], limit_array[2][3]
        ]], "nnnnnn")
  return xj_lp, xj_jp, xj_zp, mj_lp, mj_jp, mj_zp
end

local function gsg_GetRealName(aBuyInfo)
  local realName = aBuyInfo
  local maxCount = -1
  local bDel = false
  if string.find(aBuyInfo, "*", nil, true) then
    _, _, realName, maxCount = string.find(aBuyInfo, "(.-)%*(%d+)")
    maxCount = tonumber(maxCount)
    if realName and maxCount then
    else
      PushColorMsg(aBuyInfo .. " 设置有误")
      bDel = true
    end
  end
  return realName, maxCount, bDel
end

function _SMain(...)
  local g_Limit = {
    {
      120,
      40,
      8
    },
    {
      1,
      1,
      1
    },
    {
      20,
      10,
      5
    }
  }
  local strXJ = GetConfigText("归山阁购物", "心诀名称")
  local strMJ = GetConfigText("归山阁购物", "秘技名称")
  m_param.buyxinjue = SplitString(strXJ, " ", true)
  m_param.buymiji = SplitString(strMJ, " ", true)
  local m_data = {}
  local tickOut = -1
  while true do
    if IsWindowVisible("NewDungeon_DaibiShop") then
      if #m_param.buyxinjue > 0 then
        for i = 1, 3 do
          GetLuaValue("setmetatable(_G, {__index = NewDungeon_DaibiShop_Env});NewDungeon_DaibiShop_ChangeShowTab(1)")
          Sleep(600)
          local realName, maxCount, bDel = gsg_GetRealName(m_param.buyxinjue[1])
          if bDel then
            table.remove(m_param.buyxinjue, 1)
            break
          end
          local buyCount = maxCount
          if buyCount > 0 then
            if nil == m_data[realName] then
              m_data[realName] = {}
              m_data[realName].oldCount = Bag:GetItemCount(realName)
              m_data[realName].nowCount = m_data[realName].oldCount
            else
              m_data[realName].nowCount = Bag:GetItemCount(realName)
              local haveBuy = m_data[realName].nowCount - m_data[realName].oldCount
              if buyCount <= haveBuy then
                PushColorMsg(realName .. "：已购买指定数量")
                table.remove(m_param.buyxinjue, 1)
                break
              else
                buyCount = buyCount - haveBuy
              end
            end
          end
          local nBuyType, itemType = GetLuaValue(fmt("return dmBuyShanHaiItem([[%s]], %d)", realName, buyCount), "nn")
          Sleep(500)
          if 0 ~= nBuyType then
            if 2 == nBuyType then
              PushColorMsg("购买：" .. realName .. " 历练值不足")
              table.remove(m_param.buyxinjue, 1)
              break
            end
            if 1 == nBuyType then
              local xj_lp, xj_jp, xj_zp, mj_lp, mj_jp, mj_zp = ShanHai_GetLimit()
              local thisLimit = 0
              if 1 == itemType then
                thisLimit = g_Limit[1][1] - xj_lp
              elseif 2 == itemType then
                thisLimit = g_Limit[1][2] - xj_jp
              elseif 3 == itemType then
                thisLimit = g_Limit[1][3] - xj_zp
              end
              if thisLimit <= 0 then
                PushColorMsg("购买：" .. realName .. " 超出限购数量")
                table.remove(m_param.buyxinjue, 1)
              end
            end
            break
          end
          if 3 == i then
            PushColorMsg(m_script_name .. "：没有找到" .. realName)
            table.remove(m_param.buyxinjue, 1)
          end
        end
      elseif #m_param.buymiji > 0 then
        for i = 1, 3 do
          GetLuaValue("setmetatable(_G, {__index = NewDungeon_DaibiShop_Env});NewDungeon_DaibiShop_ChangeShowTab(2)")
          Sleep(600)
          local realName, maxCount, bDel = gsg_GetRealName(m_param.buymiji[1])
          if bDel then
            table.remove(m_param.buymiji, 1)
            break
          end
          local buyCount = maxCount
          if buyCount > 0 then
            if nil == m_data[realName] then
              m_data[realName] = {}
              m_data[realName].oldCount = Bag:GetItemCount(realName)
              m_data[realName].nowCount = m_data[realName].oldCount
            else
              m_data[realName].nowCount = Bag:GetItemCount(realName)
              local haveBuy = m_data[realName].nowCount - m_data[realName].oldCount
              if buyCount <= haveBuy then
                table.remove(m_param.buymiji, 1)
                break
              else
                buyCount = buyCount - haveBuy
              end
            end
          end
          local nBuyType, itemType = GetLuaValue(fmt("return dmBuyShanHaiItem([[%s]], %d)", realName, buyCount), "nn")
          Sleep(500)
          if 0 ~= nBuyType then
            if 2 == nBuyType then
              PushColorMsg("购买：" .. realName .. " 历练值不足")
              table.remove(m_param.buymiji, 1)
              break
            end
            if 1 == nBuyType then
              local xj_lp, xj_jp, xj_zp, mj_lp, mj_jp, mj_zp = ShanHai_GetLimit()
              local thisLimit = 0
              if 1 == itemType then
                thisLimit = g_Limit[2][1] - mj_lp
              elseif 2 == itemType then
                thisLimit = g_Limit[2][2] - mj_jp
              elseif 3 == itemType then
                thisLimit = g_Limit[2][3] - mj_zp
              end
              if thisLimit <= 0 then
                PushColorMsg("购买：" .. realName .. " 超出购买数量")
                table.remove(m_param.buymiji, 1)
              end
            end
            break
          end
          if 3 == i then
            PushColorMsg(m_script_name .. "：没有找到" .. realName)
            table.remove(m_param.buymiji, 1)
          end
        end
      else
        break
      end
    else
      GoToSceneNPC("沈寒洲", 210, 51, 2)
      Sleep(500)
      DialogOptionClicked("归山阁", 1, 1000)
    end
    if -1 == tickOut then
      tickOut = GetTickCount()
    end
    if GetTickCount() - tickOut > 180000 then
      PushColorMsg(m_script_name .. ":超时")
    end
    Sleep(500)
    DebugStr(m_script_name)
  end
  CloseAllWindow()
end

_SMain()
ScriptOnStop(m_script_name)
