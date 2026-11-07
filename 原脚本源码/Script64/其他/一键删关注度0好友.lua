-- 反编译自 dfz64.dll 内嵌字节码 002a7084（unluac 2025-12-23；仅供分析）
function _SMain(...)
  local function _DelFriend()
    for i = 1, 4 do
      local n1 = GetLuaValue(fmt("local fCount = DataPool:GetFriendNumber(%d) return fCount", i), "n")
      
      for j = 0, n1 - 1 do
        local strText = fmt([[
                        local i,j = %d, %d
                        local szName = ""
                        local guid = DataPool:GetFriend(i, j, "ID");
                        local name = DataPool:GetFriend(i, j, "NAME");
                        local ntype = DataPool:GetFriend(i, j, "RELATION_TYPE")
                        local value = DataPool:GetFriend(i,j,"FRIENDVALUE");
                        if value == 0 and ntype == 1 then
                            DataPool:DelFriend(i, j);
                            szName = name
                        end
                        return szName
                    ]], i, j)
        local szDelName = GetLuaValue(strText, "s")
        if "" ~= szDelName then
          PushDebugMessage("分组%d: 关注0删除 %s", i, szDelName)
          return true
        end
      end
    end
    return false
  end
  
  local tick_out = GetTickCount()
  local n = GetLuaValue("local fCount = DataPool:GetFriendNumber(1) + DataPool:GetFriendNumber(2) + DataPool:GetFriendNumber(3) + DataPool:GetFriendNumber(4); return fCount", "n", 1)
  while _DelFriend() do
    Sleep(555)
    if GetTickCount() - tick_out > 90000 then
      break
    end
  end
  n = n - GetLuaValue("local fCount = DataPool:GetFriendNumber(1) + DataPool:GetFriendNumber(2) + DataPool:GetFriendNumber(3) + DataPool:GetFriendNumber(4); return fCount", "n")
  PushColorMsg("删除关注0好友：" .. n .. "个")
end

_SMain()
