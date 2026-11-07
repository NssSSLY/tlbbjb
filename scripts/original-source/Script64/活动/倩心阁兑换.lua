-- 反编译自 dfz64.dll 内嵌字节码 00439737（unluac 2025-12-23；仅供分析）
local m_script_name = "倩心阁兑换"
ScriptOnStart(m_script_name, true, true)
local qxgdh = ReadConfigText("ZH", "bjk202")
PushColorMsg(qxgdh)

function split(str, reps)
  local resultStrList = {}
  string.gsub(str, "[^" .. reps .. "]+", function(w)
    table.insert(resultStrList, w)
  end)
  return resultStrList
end

function dhOnload(dhIndex)
  DeleteDebugMsg("#{DHSD_20240522_29")
  DeleteDebugMsg("#{DHSD_20240522_25}")
  while true do
    local strText = [[
            setmetatable(_G, {__index = DaHuaQiXi_Shop_Env});
            DaHuaQiXi_Shop_Clicked(%d)
        ]]
    local strTemp = fmt(strText, dhIndex)
    GetLuaValue(strTemp)
    Sleep(200)
    GetLuaValue("setmetatable(_G, {__index = MessageBox_Self3_Env});MessageBox_Self3_OnOk()")
    local nTransTime = GetSceneTransTime()
    local nMsg1, szMsgText, nMsgTime1 = IsInDebugMsgTime("#{DHSD_20240522_29", nil, 1001)
    if nMsg1 and nTransTime < nMsgTime1 then
      break
    end
    local nMsg1, szMsgText, nMsgTime1 = IsInDebugMsgTime("#{DHSD_20240522_25", nil, 1001)
    if nMsg1 and nTransTime < nMsgTime1 then
      break
    end
  end
end

function _SMain(...)
  Team:LeaveTeam()
  GetLuaValue("setmetatable(_G, {__index = PlayerQuicklyEnter_Env});PlayerQuicklyEnter_Clicked(77);")
  Sleep(1000)
  GetLuaValue("setmetatable(_G, {__index = Qixi_HuaJuan_Env});Qixi_HuaJuan_ShopButton_Clicked();")
  Sleep(1000)
  local dhObj = split(qxgdh, " ")
  if #dhObj > 0 then
    for i = 1, #dhObj do
      if "兰若幽帘礼匣" == dhObj[i] then
        local dhIndex = 1
        dhOnload(dhIndex)
      end
      if "诗画录礼匣" == dhObj[i] then
        local dhIndex = 2
        dhOnload(dhIndex)
      end
      if "驱邪刃影礼匣" == dhObj[i] then
        local dhIndex = 3
        dhOnload(dhIndex)
      end
      if "3级秘银" == dhObj[i] then
        local dhIndex = 4
        dhOnload(dhIndex)
      end
      if "3级棉布" == dhObj[i] then
        local dhIndex = 5
        dhOnload(dhIndex)
      end
      if "觉灵珠" == dhObj[i] then
        local dhIndex = 6
        dhOnload(dhIndex)
      end
      if "四绘流光匣" == dhObj[i] then
        local dhIndex = 7
        dhOnload(dhIndex)
      end
      if "虹耀石" == dhObj[i] then
        local dhIndex = 8
        dhOnload(dhIndex)
      end
      if "缀梦灵石" == dhObj[i] then
        local dhIndex = 9
        dhOnload(dhIndex)
      end
      if "金蚕丝" == dhObj[i] then
        local dhIndex = 10
        dhOnload(dhIndex)
      end
      if "紫府星髓" == dhObj[i] then
        local dhIndex = 11
        dhOnload(dhIndex)
      end
    end
  end
end

_SMain()
ScriptOnStop(m_script_name, true)
