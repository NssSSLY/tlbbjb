-- 反编译自 dfz64.dll 内嵌字节码 00472c05（unluac 2025-12-23；仅供分析）
local m_script_name = "购买寒纹玉物品"
ScriptOnStart(m_script_name)

function _SMain(...)
  CloseAllWindow()
  local buyItemName = HandleText_AddFuHao(GetConfigText("寒纹玉购物", "物品名称"))
  local tickOut = GetTickCount()
  while true do
    if not IsWindowVisible("ActivitySchedule_Shop") then
      if not IsWindowVisible("TodayCampaignListNew") then
        GetLuaValue("setmetatable(_G, {__index = PlayerQuicklyEnter_Env}); PlayerQuicklyEnter_ActivityShedule()")
        Sleep(300)
      end
      if not IsWindowVisible("ActivitySchedule_Shop") then
        GetLuaValue("setmetatable(_G, {__index = TodayCampaignListNew_Env}); TodayCampaignListNew_WeeklyShop_Clicked()")
        Sleep(800)
      end
    end
    local strText = fmt("            local allItem = \"%s\"\n            local shopType = 1\n            local pageCount = 15\n            local allCnt = GetHuoYueShopTotalCount(shopType)\n            local allPage = math.ceil(allCnt / pageCount)\n            local nhigh_total, nlow_total = GetHuoYueShopDaiBiInfo()\n            local bBuy = 0\n            for j = 1, allPage do\n                local tblinfo = GetHuoYueShopData(shopType, j, pageCount)\n                for i = 1, table.getn(tblinfo) do\n                    --第一列\n                    local itemid = tblinfo[i].itemid\n                    local itemnum = tblinfo[i].itemnum\n                    local daibitype = tblinfo[i].daibitype\n                    local daibinum = tblinfo[i].daibinum\n                    local limitday = tblinfo[i].limitday\n                    local limitday_self = tblinfo[i].limitday_self\n                    local limitweek = tblinfo[i].limitweek\n                    local limitweek_self = tblinfo[i].limitweek_self\n                    local limitmonth = tblinfo[i].limitmonth\n                    local limitmonth_self = tblinfo[i].limitmonth_self\n                    local limitfov = tblinfo[i].limitfov\n                    local limitfov_self = tblinfo[i].limitfov_self\n                    local yulan = tblinfo[i].yulan\n                    local huoyueweek = tblinfo[i].huoyueweek\n                    local isshowunbind = tblinfo[i].isshowunbind\n    \n                    local ndaibicount = 0\n                    local nBuyNum = 0\n                    if daibitype == 1 then\n                        ndaibicount = nhigh_total\n                    else\n                        ndaibicount = nlow_total\n                    end\n                    local nislimit = 0\n                    local limitnum = 0\n                    if limitday == 0 and limitweek == 0 and limitmonth == 0 and limitfov == 0 then\n                        nislimit = 0\n                    elseif limitday > 0 then\n                        nislimit = 1\n                        limitnum = limitday_self\n                    elseif limitweek > 0 then\n                        nislimit = 1\n                        limitnum = limitweek_self\n                    elseif limitmonth > 0 then\n                        nislimit = 1\n                        limitnum = limitmonth_self\n                    elseif limitfov > 0 then\n                        nislimit = 1\n                        limitnum = limitfov_self\n                    end\n                    local maxNum = HuoYueShopCalcMaxNumCanBuy(itemid, itemnum, shopType, ndaibicount, daibinum, nislimit, limitnum, 0)\n                    if maxNum > 0 then\n                        local itemName = DataPool:Lua_GetItemNameByIndex(itemid)\n                        if string.find(allItem, \" \" .. itemName .. \" \", nil, true) then\n                            meTestMsg(\"购买：\" .. itemName)\n                            Clear_XSCRIPT()\n                            Set_XSCRIPT_Function_Name(\"BuyItem\")\n                            Set_XSCRIPT_ScriptID(888393)\n                            Set_XSCRIPT_Parameter(0, -1)\n                            Set_XSCRIPT_Parameter(1, shopType)\n                            Set_XSCRIPT_Parameter(2, itemid)\n                            Set_XSCRIPT_Parameter(3, maxNum)\n                            Set_XSCRIPT_ParamCount(4) -- 参数个数\n                            Send_XSCRIPT()\n                            bBuy = 1\n                            break\n                        end\n                    end\n                end\n                if bBuy == 1 then\n                    break\n                end\n            end\n            return bBuy\n        ", buyItemName)
    if IsWindowVisible("ActivitySchedule_Shop") then
      if not GetLuaValue(strText, "b") then
        PushColorMsg("华玉集：没有可购买的物品")
        break
      end
      CloseAllWindow()
    end
    if GetTickCount() - tickOut > 60000 then
      PushColorMsg("华玉集：购买超时")
      break
    end
    Sleep(500)
  end
  CloseAllWindow()
end

_SMain()
ScriptOnStop(m_script_name)
