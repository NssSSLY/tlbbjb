-- 反编译自 dfz64.dll 内嵌字节码 002a7741（unluac 2025-12-23；仅供分析）
function _SMain(...)
  local function _DelFriend_ship0()
    for i = 1, 4 do
      local n1 = GetLuaValue(fmt("local fCount = DataPool:GetFriendNumber(%d) return fCount", i), "n")
      
      for j = n1 - 1, 0, -1 do
        local strText = fmt([[
                        local i,j = %d,%d
                        local szName = ""
                        local guid = DataPool:GetFriend(i, j, "ID");
                        local name = DataPool:GetFriend(i, j, "NAME");
                        local ntype = DataPool:GetFriend(i, j, "RELATION_TYPE") -- and ntype == 1
                        local value = DataPool:GetFriend(i,j,"FRIENDSHIP");
                        if value == 0 then
                            DataPool:DelFriend(i, j);
                            szName = name
                        end
                        return szName
                    ]], i, j)
        local szDelName = GetLuaValue(strText, "s")
        if "" ~= szDelName then
          PushColorMsg("分组%d: 友好0删除 %s", i, szDelName)
          return true
        end
      end
    end
    return false
  end
  
  local nTick = GetTickCount()
  local n = GetLuaValue("local fCount = DataPool:GetFriendNumber(1) + DataPool:GetFriendNumber(2) + DataPool:GetFriendNumber(3) + DataPool:GetFriendNumber(4); return fCount", "n")
  while _DelFriend_ship0() do
    Sleep(555)
    if GetTickCount() - nTick > 90000 then
      break
    end
  end
  n = n - GetLuaValue("local fCount = DataPool:GetFriendNumber(1) + DataPool:GetFriendNumber(2) + DataPool:GetFriendNumber(3) + DataPool:GetFriendNumber(4); return fCount", "n")
  PushColorMsg("删除友好0好友：" .. n .. "个")
end

_SMain()
