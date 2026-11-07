-- 反编译自 dfz64.dll 内嵌字节码 00382f48（unluac 2025-12-23；仅供分析）
local g_t = {}
local g_t2 = {}
local g_SelfName = Player:GetName()

function SW_Tongji()
  local tObj = Enum2XByClass("玩家")
  for i = 1, #tObj do
    if 0 ~= tObj[i].id and tObj[i].name ~= g_SelfName then
      local bJoin = true
      for j = 1, #g_t do
        if tObj[i].name == g_t[j].name then
          if g_t[j].id ~= tObj[i].id then
            g_t[j].id = tObj[i].id
            g_t[j].dst = g_t[j].dst + 1
          elseif g_t[j].guildname == "无帮会" then
            local szname = tObj[i].bhname
            if "" == szname then
              szname = "无帮会"
            end
            g_t[j].guildname = szname
          end
          bJoin = false
          break
        end
      end
      if bJoin then
        local szname = tObj[i].bhname
        if "" == szname then
          szname = "无帮会"
        end
        local n = #g_t + 1
        g_t[n] = {
          id = tObj[i].id,
          name = tObj[i].name,
          guildname = szname,
          dst = 1
        }
      end
    end
  end
  g_t2 = {}
  for i = 1, #g_t do
    local bJoin = true
    for j = 1, #g_t2 do
      if g_t2[j].guildname == g_t[i].guildname then
        g_t2[j].dst = g_t2[j].dst + g_t[i].dst
        bJoin = false
        break
      end
    end
    if bJoin then
      local n = #g_t2 + 1
      g_t2[n] = {
        guildname = g_t[i].guildname,
        dst = g_t[i].dst
      }
    end
  end
  BubbleByDst(g_t, 2)
  BubbleByDst(g_t2, 2)
  local n1 = #g_t
  local n2 = #g_t2
  local szText1 = "\r\n----------------个人死亡排名----------------\r\n"
  local szText2 = "\r\n----------------帮派死亡排名----------------\r\n"
  for i = 1, n1 do
    szText1 = szText1 .. string.format("%-20s %-6s", g_t[i].name, g_t[i].dst) .. "\r\n"
  end
  for i = 1, n2 do
    szText2 = szText2 .. string.format("%-20s %-6s", g_t2[i].guildname, g_t2[i].dst) .. "\r\n"
  end
end

function _SMain(...)
  if "" == g_SelfName then
    g_SelfName = "自己"
  end
  while true do
    local szSceneName = GetCurrentSceneName()
    if "地府" == szSceneName then
      SW_Tongji()
    else
      DebugStr("当前不在地府，暂时不统计。。")
    end
    Sleep(800)
  end
end

_SMain()
