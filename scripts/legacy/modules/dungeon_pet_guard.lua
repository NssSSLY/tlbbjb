-- Use the game's own recall/deploy actions. Preserve the exact roster GUID;
-- an unconfirmed action is observed again, never replayed blindly.
DungeonPetGuard={}
local R=assert(CombatRuntime)
local function raw(code,format) return GetLuaValue(code,format or '',format and #format or 0) end
local function init()
    raw([[-- dungeon:pet-guard-init
        __tlbbDungeonPet={}
        function __tlbbDungeonPet.flag(v)
            if v==1 or v==true then return 1 end
            if v==0 or v==false then return 0 end
            error('pet state unavailable')
        end
        function __tlbbDungeonPet.read(i)
            if __tlbbDungeonPet.flag(Pet:IsPresent(i))~=1 then return -1,0,0 end
            local h,l=Pet:GetGUID(i)
            if type(h)~='number' or type(l)~='number' or h~=math.floor(h) or l~=math.floor(l)
                or h<0 or h>4294967295 or l<0 or l>4294967295 then error('pet GUID unavailable') end
            return h,l,__tlbbDungeonPet.flag(Pet:GetIsFighting(i))
        end
        function __tlbbDungeonPet.find()
            local found=-1 local high=0 local low=0
            for i=0,9 do local h,l,on=__tlbbDungeonPet.read(i)
                if h~=-1 and on==1 then
                    if found~=-1 then error('multiple deployed pets') end
                    found=i high=h low=l
                end
            end
            return found,high,low
        end
        function __tlbbDungeonPet.submit(i,h,l,deployed)
            local hh,ll,on=__tlbbDungeonPet.read(i)
            if hh~=h or ll~=l then error('pet identity changed before command') end
            if on==deployed then return 0 end
            local active,ah,al=__tlbbDungeonPet.find()
            if deployed==1 and active~=-1 then error('another pet deployed during guard') end
            if deployed==0 and (active~=i or ah~=h or al~=l) then error('deployed pet changed') end
            local a
            if deployed==0 then a=Pet:GetPetRelaxAction()
            else Pet:SetSelectPetIdx(i) a=Pet:GetPetFightAction() end
            if not a or type(a.GetID)~='function' then error('pet command action unavailable') end
            local id=a:GetID()
            if type(id)~='number' or id~=math.floor(id) or id<=0 then error('pet action ID unavailable') end
            if __tlbbDungeonPet.flag(a:IsEnable())~=1 then return 2 end
            if __tlbbDungeonPet.flag(DataPool:IsCanDoAction())~=1 then return 2 end
            local b=Packet_Env.Packet_Space_Line10_Row10_button
            local previous=b:GetActionItem();b:SetActionItem(id)
            local ok,why=pcall(b.DoAction,b);b:SetActionItem(previous)
            if not ok then error(why) end
            return 1
        end
    ]])
end
function DungeonPetGuard.new()
    init();return {phase='idle',at=0}
end
function DungeonPetGuard.update(s,hold)
    local now=GetTickCount()
    if s.phase=='idle' then
        if not hold then return true end
        local i,h,l=raw('return __tlbbDungeonPet.find()','nnn')
        assert(i>=-1 and i<=9 and i==math.floor(i),'珍兽槽位不可读')
        if i==-1 then return true end
        assert(type(h)=='number' and type(l)=='number','珍兽身份不可读')
        s.pet={index=i,high=h,low=l};s.phase='recall';s.at=now;s.issued=false
    end
    local p=s.pet
    local h,l,on=raw(string.format('return __tlbbDungeonPet.read(%d)',p.index),'nnn')
    assert(h==p.high and l==p.low,'机制期间珍兽身份变化，停止自动恢复出战')
    assert(on==0 or on==1,'珍兽出战状态不可读')
    if s.phase=='recalled' then
        assert(on==0,'机制期间珍兽被手动出战，请停止后重新运行')
        if hold then return true end
        s.phase='deploy';s.at=now
    end
    local wanted=(s.phase=='deploy' or s.phase=='deploy_wait') and 1 or 0
    if on==wanted then
        if wanted==0 then
            assert(s.issued,'珍兽在脚本休息指令前被手动收回，请停止后重新运行')
            s.phase='recalled';R.log('机制停手：已确认珍兽休息');return hold
        end
        assert(not R.setPetSuspended or R.setPetSuspended(false,p),'恢复珍兽维护失败')
        s.phase='idle';s.pet=nil;R.log('机制结束：已确认原珍兽恢复出战');return not hold
    end
    assert(now-s.at<8000,'珍兽指令后状态未确认，停止且不重复提交')
    if s.phase=='recall' then
        if R.setPetSuspended and not R.setPetSuspended(true,p) then return false end
    end
    if s.phase=='recall' or s.phase=='deploy' then
        local result=raw(string.format('return __tlbbDungeonPet.submit(%d,%.0f,%.0f,%d)',p.index,p.high,p.low,wanted),'n')
        assert(result==0 or result==1 or result==2,'珍兽指令结果不可读')
        if result==1 then s.phase=wanted==0 and 'recall_wait' or 'deploy_wait';s.issued=true end
    end
    return false
end
