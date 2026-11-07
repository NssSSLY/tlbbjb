-- 扫荡副本, written from the reference rules (原脚本源码/Script64/副本/扫荡副本.lua, 系统/functions.lua SDFB_OnStart). Works the game's own sweep windows.
-- The reference's clean-up (eating bound items, ClearBag, selling, banking) is not ported: nothing here deletes or sells anything.
-- This task owns its stages and receipts; it does not load the vendor framework. docs/SAODANG_HANDOFF.md names the differences.
LoadScript('shaoshi')
Saodang={}
local DUNGEONS={
    {name='讨伐燕子坞',key='xzk131'},
    {name='苏州四绝庄',key='xzk266'},
    {name='少室山',key='xzk274'},
    {name='兵圣奇阵',key='xzk272'},
    {name='凤鸣王陵',key='xzk279'},
    {name='三神幻境',key='xzk278'},
    {name='挑战缥缈峰',key='xzk275'},
    {name='琅嬛福地（普通）',key='xzk277'},
    {name='琅嬛福地（困难）',key='xzk276'},
    {name='除匪首力破三关',key='xzk290'},
}
local BLOCK_KEYS={'SDXG_20210624_29','SDXG_20210624_30','SDXG_20210624_31','SDXG_20210624_32','SDXG_20210624_33','SDXG_20210624_34','SDXG_20210624_35','SDXG_20210624_36','SDXG_20210624_37'}
local DONE_KEYS={'FBSD_150126_50','FBSD_150126_51','FBSD_150126_52','FBSD_150126_70','SDXG_20210624_16','SDXG_20210624_17'}
local FULL_KEYS={'FBSD_150126_33','FBSD_150126_34'}
local MAX_TRIES=3
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end

function Saodang.run(injected)
    local api=injected or Shaoshi.newApi();local cfg=TaskConfig or {}
    local waitMs=int(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local limitMs=int(tonumber(cfg.saodang_minutes or 20),1,120,'总时限')*60000
    local wanted,any={},false
    for _,d in ipairs(DUNGEONS) do
        assert(cfg[d.key]==nil or type(cfg[d.key])=='boolean','扫荡开关无效：'..d.key)
        if cfg[d.key]==true then wanted[d.name]=d;any=true end
    end
    -- Doubling a 三神 chest spends a 天星灵符; that needs the risk switch, and otherwise the free one is taken.
    local useKey=cfg.allow_item==true
    local def={name='扫荡副本',mission='扫荡副本',map='',npc={name='',x=0,y=0,scene=0},bosses={}}
    function def.inside() return false end
    local phase='';local function log(s) if phase~=s then phase=s;api.log('扫荡副本 · '..s) end end
    local function raw(tag,code,format) return GetLuaValue('-- saodang:'..tag..'\n'..code,format or '',format and #format or 0) end
    local PREFIX="local function g(e,n) if type(e)=='table' and e[n] then return e[n] end return _G[n] end\n"
    -- Prompts count from here on; what is already on screen is history.
    local base={}
    local function count(key)
        local phrase=GetDictionaryString and GetDictionaryString(key) or nil
        local n=0
        for _,line in ipairs(api.messages()) do
            if line:find(key,1,true) or (type(phrase)=='string' and phrase~='' and line:find(phrase,1,true)) then n=n+1 end
        end
        return n
    end
    local function mark(keys) for _,k in ipairs(keys) do base[k]=count(k) end end
    local function firedAny(keys) for _,k in ipairs(keys) do if count(k)>(base[k] or 0) then return k end end end
    local function shown(window) return raw('shown',string.format("local e=%s_Env if type(e)=='table' and e.this and e.this:IsVisible() then return 1 end return 0",window),'n')==1 end
    local function openBox()
        raw('open-box',PREFIX.."local e=PlayerQuicklyEnter_Env g(e,'PlayerQuicklyEnter_OpenSecKillBox')()")
    end
    local function closePage()
        raw('close-page',"local e=SweepPage_Env if type(e)=='table' and e.this and e.this:IsVisible() then e.this:Hide() end")
    end
    local function list()
        local n=raw('count',"return GetSecKillFuBenCount()",'n')
        assert(type(n)=='number' and n>=0 and n<=64,'扫荡列表数量不可读')
        local out={}
        for i=0,n-1 do
            local name,low,high,kind,need,action,left,id=raw('enum',PREFIX..string.format([[local e=SweepAll_Env
                local Id,Icon,FubenName,needLevel,Low,High,NumType,Need,CanDouble,Yuanbao,ActionID=g(e,'EnumSecKillTable')(%d)
                local total=g(e,'GetCampaignTotalNum')(ActionID)
                local left=total-g(e,'GetCampaignCountNum')(ActionID)
                local fid=g(e,'Lua_SecKillGetFuBenIndexID_New')(%d)
                if FubenName==nil or FubenName=='' then FubenName='nil' end
                return FubenName,Low,High,NumType,Need,ActionID,left,fid]],i,i),'snnnnnnn')
            out[#out+1]={name=name,low=low or 0,high=high or 0,kind=kind,need=need or 0,left=left or 0,id=id}
        end
        return out
    end
    local function session()
        local active,id=raw('session',"local a,b=GetSecKillData() return a,b",'nn')
        return active==1,id
    end
    -- One dungeon's page. Returns the blocking prompt when its achievement is too low.
    local function sweepPage(name)
        mark(DONE_KEYS);mark(BLOCK_KEYS);mark(FULL_KEYS)
        local began=api.now()
        while shown('SweepPage') do
            assert(api.now()-began<math.max(waitMs,60000),'扫荡副本：'..name..' 超过 1 分钟没有结束')
            local step=raw('step',[[local e=SweepPage_Env
                if e.SecKillItemListEmpty()~=1 then return 0 end
                local title=e.SweepPage_DragTitle:GetText()
                local names={e.SweepPage_Boss1Name,e.SweepPage_Boss2Name,e.SweepPage_Boss3Name,e.SweepPage_Boss4Name,e.SweepPage_Boss5Name,e.SweepPage_Boss6Name}
                local die={e.SweepPage_Boss1finish,e.SweepPage_Boss2finish,e.SweepPage_Boss3finish,e.SweepPage_Boss4finish,e.SweepPage_Boss5finish,e.SweepPage_Boss6finish}
                for i=1,6 do
                    if names[i]:IsVisible() and not die[i]:IsVisible() then
                        if i>3 and string.find(title,'扫荡三神幻境',1,true) then e.SweepPage_OnBossButton(4) return -2 end
                        e.SweepPage_OnBossButton(i) return i
                    end
                end
                return -1]],'n')
            api.sleep(500)
            if firedAny(FULL_KEYS) then error('扫荡副本：背包已满，已停止（不自动清理或出售），整理后重新运行',0) end
            local blocked=firedAny(BLOCK_KEYS)
            if blocked then log(name..' 成就不足');return blocked end
            if shown('SanShen_BaoXiang') then
                local keys=0
                if useKey then
                    keys=raw('keys',[[local c=0
                        for i=0,DataPool:GetBaseBag_Num()-1 do local a=PlayerPackage:EnumItem('base',i)
                            if a and a:GetID()~=0 and a:GetName()=='天星灵符' then c=c+a:GetNum() end end
                        return c]],'n') or 0
                end
                raw('chest',keys>0 and "SanShen_BaoXiang_Env.SanShen_BaoXiang_OpenLingfu()" or "SanShen_BaoXiang_Env.SanShen_BaoXiang_OpenFree()")
                api.sleep(200);raw('ok',"SweepPage_Env.SweepPage_OnOkClicked()")
                return nil
            end
            if step<0 then return nil end
            api.sleep(500);raw('ok',"SweepPage_Env.SweepPage_OnOkClicked()");api.sleep(1000)
            if firedAny(DONE_KEYS) then return nil end
        end
    end
    local function openPage(id)
        closePage();api.sleep(100)
        local began=api.now()
        repeat
            raw('open-page',PREFIX..string.format("local e=SweepAll_Env g(e,'OpenSecKillPage')(%d,0)",id));api.sleep(800)
            if shown('SweepPage') then return true end
        until api.now()-began>=5000
        return false
    end

    local function body()
        api.validate(def,cfg)
        assert(any,'扫荡副本：没有勾选要扫荡的副本')
        local start=api.now()
        local tries,done,skipped={},{},{}
        local swept=0
        local function ensureBox()
            if shown('SweepAll') then return end
            openBox();api.sleep(1000)
            assert(shown('SweepAll'),'扫荡副本：扫荡窗口打不开')
        end
        while true do
            assert(api.now()-start<limitMs,'扫荡副本超过总时限')
            ensureBox()
            local rows=list()
            local byId={};for _,r in ipairs(rows) do byId[r.id]=r end
            local active,activeId=session()
            local pick
            if active then
                pick=byId[activeId] or {name='未完成的副本',id=activeId,left=1}
                log('继续未扫荡完的 '..pick.name)
            else
                for _,r in ipairs(rows) do
                    if wanted[r.name] and r.left>0 and not skipped[r.name] then
                        local points=r.kind==2 and r.high or r.low
                        if r.need<=points then pick=r;break end
                        skipped[r.name]='点数不足（剩 '..math.floor(points)..'，需要 '..math.floor(r.need)..'）'
                        api.log('扫荡副本：'..r.name..' '..skipped[r.name])
                    end
                end
            end
            if not pick then break end
            tries[pick.name]=(tries[pick.name] or 0)+1
            if tries[pick.name]>MAX_TRIES then
                if active then error('扫荡副本：'..pick.name..' 一直未完成，已停止',0) end
                skipped[pick.name]='尝试 '..MAX_TRIES..' 次次数没有变化'
                api.log('扫荡副本：'..pick.name..' '..skipped[pick.name])
            else
                log('扫荡 '..pick.name)
                local before=pick.left
                if openPage(pick.id) then
                    local blocked=sweepPage(pick.name)
                    closePage();api.sleep(500)
                    if blocked then skipped[pick.name]='成就不足' end
                    ensureBox()
                    for _,r in ipairs(list()) do
                        if r.id==pick.id and r.left<before then
                            swept=swept+(before-r.left);done[r.name]=(done[r.name] or 0)+(before-r.left);tries[r.name]=0
                        end
                    end
                else
                    api.log('扫荡副本：'..pick.name..' 的页面打不开')
                end
            end
            api.maintain();api.sleep(1000)
        end
        closePage()
        local parts={}
        for name,n in pairs(done) do parts[#parts+1]=name..' '..math.floor(n)..' 次' end
        for name,why in pairs(skipped) do parts[#parts+1]=name..'：'..why end
        table.sort(parts)
        local text=#parts>0 and table.concat(parts,'；') or '没有可扫荡的副本'
        if swept==0 and next(skipped)~=nil then error('扫荡副本：没有扫成任何副本。'..text,0) end
        return {status=swept>0 and 'done' or 'already_done',message='扫荡副本：'..text}
    end
    local ok,result=pcall(body)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    return TaskLifecycle.report(result.status,result.message)
end
