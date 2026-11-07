-- 对拍 daguai 原字节码中的 CDG:checkMP 与手工还原版本：用法 lua 本文件 <原函数.luac> <还原.lua>
-- 两边使用同一伪随机序列模拟游戏接口，比较返回值和完整调用序列（中文字符串编码不同，只比长度外的部分）。
local orig=io.open(arg[1],"rb"):read("a")
local mine=io.open(arg[2],"rb"):read("a")
local function env(seed,trace)
  local x=seed
  local function rnd(n) x=(x*1103515245+12345)%2147483648; return x%n end
  local tick=0
  local E={}
  local function rec(...) local t={...} for i=1,#t do t[i]=tostring(t[i]) end trace[#trace+1]=table.concat(t,",") end
  E.Player={GetMPP=function() local v=rnd(101); rec("GetMPP",v); return v end,
            GetFightPetGUID=function() local v=({0,5,7,-1})[rnd(4)+1]; rec("Guid",v); return v end,
            GetBuff=function(_,n) local v=rnd(3)==0 and 3 or -1; rec("Buff",#n,v); return v end}
  E.GetTickCount=function() tick=tick+rnd(4000); rec("Tick"); return tick end
  E.Sleep=function(n) rec("Sleep",n) end
  E.PushColorMsg=function(m) rec("Msg",#m) end
  E.GetLuaValue=function(c,f) local v=rnd(2)==0; rec("Lua",#c,f,v); return v end
  E.Bag={SearchItemName=function(_,n) local c=rnd(3); local t={} for i=1,c do t[i]={index=rnd(50)} end rec("Search",#n,c); return t end,
         UseItem=function(_,i,d) rec("Use",i,d) end}
  E.Pet={Relax=function(...) rec("Relax",select('#',...)) end}
  local cdg={mp={cmp=({0,30,60,90,97})[rnd(5)+1]},pet3={GUID=({0,5,7})[rnd(3)+1]},pet1={GUID=({0,5,7})[rnd(3)+1]},call={}}
  local cb=rnd(3)
  if cb==1 then cdg.call.back1=function() local v=rnd(4)~=0; rec("cb",v); return v end end
  function cdg:checkHP_PetGUID(g,c) local v=rnd(101); rec("hp",g,c,v); return v end
  function cdg:checkPetPlay(g) local v=rnd(2)==0; rec("play",g,v); return v end
  E.CDG=cdg
  return E,cdg
end
local diffs=0 local cov={}
for seed=1,20000 do
  local t1,t2={},{}
  local E1,c1=env(seed,t1); local f1=assert(load(orig,"orig","b",E1))
  local a1=table.pack(pcall(f1,c1,({nil,true,false})[seed%3+1]))
  local E2,c2=env(seed,t2); assert(load(mine,"mine","t",E2))()
  local a2=table.pack(pcall(c2.checkMP,c2,({nil,true,false})[seed%3+1]))
  local s1=table.concat(t1,";"):gsub("Buff,%d+","Buff"):gsub("Msg,%d+","Msg"):gsub("Search,%d+","Search"):gsub("Lua,%d+","Lua")
  local s2=table.concat(t2,";"):gsub("Buff,%d+","Buff"):gsub("Msg,%d+","Msg"):gsub("Search,%d+","Search"):gsub("Lua,%d+","Lua")
  for _,k in ipairs({"Relax","Use,","Msg","Lua,b,true","Sleep,300","Sleep,250","cb,false"}) do if s1:find(k) then cov[k]=(cov[k] or 0)+1 end end
  if tostring(a1[1])..tostring(a1[2])~=tostring(a2[1])..tostring(a2[2]) or s1~=s2 then
    diffs=diffs+1; if diffs<4 then print("seed",seed,a1[1],a1[2],a2[1],a2[2]); print(" o",s1); print(" m",s2) end
  end
end
print("diffs",diffs) for k,v in pairs(cov) do print(k,v) end
os.exit(diffs==0 and 0 or 1)
