#include "game_lua_actions.hpp"
#include "game_text_session.hpp"
#include <cstdio>
#include <string>
using namespace tlbb;using namespace tlbb::game_lua;
// Runs every fixed snippet inside the hash-locked LuaPlus.dll (Lua 5.0) against a fake game
// environment written in Lua. No game process is touched.
static const wchar_t fakeGame[]=LR"LUA(
calls={}
local function rec(...) local t={} for i=1,table.getn(arg) do t[i]=tostring(arg[i]) end table.insert(calls,table.concat(t,",")) end
function AutoRunToTargetEx(x,y,s) rec("run",x,y,s) end
function SetAutoRunTargetNPCName(n) rec("npc",n) end
questVisible=true
buttonText="继续"
local frame={IsVisible=function(self) return questVisible end,Hide=function(self) questVisible=false rec("hide") end}
Quest_Env={this=frame,Quest_Button_Continue={GetText=function(self) return buttonText end}}
local items={{"id",0,800001,7,"#{JYQQ_250801_02}"},{"id",0,800001,8,"波斯玫瑰兑换奖励"},{"text",0,-1,-1,"说明"},{"id",0,800002,9,"#{JYQQ_250801_15}"}}
DataPool={}
function DataPool:GetNPCEventList_Num() return table.getn(items) end
function DataPool:GetNPCEventList_Item(i) local v=items[i+1] return v[1],v[2],v[3],v[4],v[5] end
function DataPool:GetBaseBag_Num() return 6 end
function DataPool:GetTeamMemberCount() return 3 end
function DataPool:GetPlayerMission_DataRound(id) if id==579 then return 6 end return 0 end
Guild={}
function Guild:GetMyGuildDetailInfo(k) if k=="ID" then return 12 end if k=="Name" then return "测试帮" end if k=="CityName" then return "测试城" end end
function Guild:AskGuildDetailInfo() rec("askguild") end
function GetDictionaryString(k) if k=="JYQQ_250801_15" then return "领取经验纳元" end return "#{"..k.."}" end
function QuestFrameOptionClicked(i,s,e) rec("option",i,s,e) end
function QuestFrameAcceptClicked() rec("accept") end
function QuestFrameMissionContinue() rec("continue") end
function QuestFrameMissionComplete(i) rec("complete",i) end
local function action(id,name,n) return {GetID=function() return id end,GetName=function() return name end,GetNum=function() return n end,IsEnable=function() return skillEnabled or 0 end} end
local bag={action(1,"波斯玫瑰",20),action(0,"",0),action(2,"波斯玫瑰",15),action(3,"红宝石（1级）",4),action(4,"红宝石（1级）",2),action(8,"低级宝石合成符",3)}
PlayerPackage={}
function PlayerPackage:EnumItem(kind,i) if kind~="base" then return nil end return bag[i+1] end
Player={}
function Player:GetData(k) if k=="YUANBAO" then return 1234 end if k=="MONEY" then return 20000 end return nil end
function Clear_XSCRIPT() rec("xs-clear") end
function Set_XSCRIPT_Function_Name(n) rec("xs-name",n) end
function Set_XSCRIPT_ScriptID(n) rec("xs-script",n) end
function Set_XSCRIPT_Parameter(i,v) rec("xs-param",i,v) end
function Set_XSCRIPT_ParamCount(n) rec("xs-count",n) end
function Send_XSCRIPT() rec("xs-send") end
Token_Shop_Env={Token_Shop_GetReward_Click=function(a) rec("token",a) end}
WuhunQuest_Env={this={IsVisible=function() return false end},WuhunQuest_Bn1Click=function() rec("wuhun") end}
MessageBox_Self_Env={this={IsVisible=function() return true end},MessageBox_Self_OK_Clicked=function() rec("msgbox") end}
routeMessage="你确认要开启跨场景自动寻路吗？"
SafeCenter_SafeScore_Env={this={IsVisible=function() return true end}}
function CloseAllWindow() rec("closeall") end
function OpenMonthlySign(n) rec("monthly-open",n) end
function PushEvent(n,a) if a then rec("event",n,a) else rec("event",n) end end
smallVisible=true
Bank={}
function Bank:GetBankMoney() return 100000,10,0,0 end
function Bank:GetMoneyFromBank(n) rec("bankget",n) end
function Bank:SaveMoneyToBank(n) rec("banksave",n) end
function Bank:GetNpcId() return 77 end
function Bank:SetOpenWhichBank(v) rec("which",v) end
function Bank:GetRentBoxInfo(i) return 0,40 end
local stored={} stored[3]=action(5,"波斯玫瑰",30) stored[25]=action(6,"波斯玫瑰",10) stored[5]=action(9,"黄宝石（2级）",5)
function Bank:EnumItem(i) return stored[i] or action(0,"",0),false end
function Bank:EnumTemItem(i) if i==2 then return action(7,"波斯玫瑰",5),false end return action(0,"",0),false end
function Bank:GetTemBankItemNum() return 1 end
function Bank:MoveAllTemBankItemToPacket() rec("tempall") end
Bank_Env={this={IsVisible=function() return smallVisible end,Hide=function() smallVisible=false rec("smallhide") end}}
BigBank_Env={this={IsVisible=function() return true end},BigBank_UpdateFrame=function(n) rec("update",n) end,BigBank_Item1_4={DoAction=function() rec("take",1,4) end}}
buttonAction=9
Packet_Env={Packet_Space_Line10_Row10_button={GetActionItem=function() return buttonAction end,SetActionItem=function(self,id) buttonAction=id rec("set",id) end,DoAction=function() rec("store") end}}
Packet_Temporary_Env={this={IsVisible=function() return true end},Packet_Temporary_ActionsList_auto_element2={GetLuaActionButton=function(self,n) return {DoAction=function() rec("temp",2,n) end} end}}
function GetSecKillFuBenCount() return 3 end
SweepAll_Env={}
function EnumSecKillTable(i) return 10+i,"icon","少室山",60,5,8,1,2,0,0,300+i end
function GetCampaignTotalNum(a) return 3 end
function GetCampaignCountNum(a) return 1 end
function Lua_SecKillGetFuBenIndexID_New(i) return 40+i end
function GetSecKillData() return 0,41,0,0 end
function Lua_SecKillGetIndexFromFuBenIndexID(f) return f-40 end
function OpenSecKillPage(id,x) rec("openpage",id,x) end
function SecKillItemListEmpty() return 1 end
local shown={IsVisible=function() return true end} local hidden={IsVisible=function() return false end}
SweepPage_Env={SweepPage_DragTitle={GetText=function() return "扫荡少室山" end},SweepPage_Boss1Name=shown,SweepPage_Boss1finish=shown,
 SweepPage_Boss2Name=shown,SweepPage_Boss2finish=hidden,SweepPage_OnBossButton=function(i) rec("boss",i) end}
function CloseWindow(n,b) rec("close",n,b) end
function GetItemBindStatus(i) if i==4 then return 1 end return 0 end
PS_ShopMag_Env={this=shown}
PlayerShop={}
function PlayerShop:GetMoney(kind,owner) if kind=="profit" and owner=="self" then return 30000 end return 0 end
function PlayerShop:ApplyMoney(k,n) rec("apply",k,n) end
Gemcompose_Env={this=shown,Gemcompose_DragTitle={GetText=function() return "宝石合成" end}}
LifeAbility={}
function LifeAbility:Do_Combine(a,b,c,d) rec("combine",a,b,c,d) end
cooldown=0
skillEnabled=1
actionReady=true
function DataPool:IsCanDoAction() return actionReady end
function EnumAction(i,kind) if kind=='skill' and i==3 then return action(301,'横扫',1) end return action(0,'',0) end
function Lua_CheckActionItemCoolDown(id) return cooldown end
selectedServer=101
function DataPool:SelectAsTargetByObjID(id) selectedServer=id rec('select',id) end
Target={IsPresent=function() return true end,GetData=function(self,k) if k=='NPCID' then if selectedServer==101 then return 10 else return 20 end end end,GetNpcName=function() return '副本怪物' end}
function Player:UseSkill() rec('attack') return 1 end
function PlayerPackage:UseItem(i) rec("use",i) end
local function boxItem(id,name) return {GetID=function() return id end,GetName=function() return name end,GetNum=function() return 1 end} end
boxBag={boxItem(11,"银丝纳福礼箱"),boxItem(0,""),boxItem(12,"银丝纳福礼箱"),boxItem(13,"其它")}
function useBoxBag() realEnum=PlayerPackage.EnumItem realBind=GetItemBindStatus PlayerPackage.EnumItem=function(self,k,i) return boxBag[i+1] end GetItemBindStatus=function(i) if i==2 then return 1 end return 0 end end
function restoreBag() PlayerPackage.EnumItem=realEnum GetItemBindStatus=realBind end
function DataPool:GetPlayerMission_InUse(i) if i==4 then return 1 end return 0 end
function DataPool:GetPlayerMission_Memo(i) return "#{SQXY_09061_4}" end
function DataPool:GetPlayerMission_Name(i) return "Mission:1234" end
function DataPool:GetPlayerMission_Variable(i,n) return n+10 end
function DataPool:GetAccVipLevel() return 5 end
function Player:GetState() return 5 end
function Player:DispelBuffByName(b) rec("dispel",b) return true end
function QuitApplication(v) rec("quit",v) end
local function shown(v) return {IsVisible=function() return v end} end
MainMenuBar_Env={MainMenuBar_Doub_Watch={IsVisible=function() return true end,GetProperty=function(self,k) if k=="Timer" then return "3600" end end}}
MessageBox_Self_Env.MessageBox_Self_Text={GetText=function() return "是否确定进行冻结？" end}
XingYun_Env={this=shown(true)}
for i=1,20 do local tip="" if i<=3 then tip="已翻" end XingYun_Env["XingYun_Head"..i]={GetToolTip=function() return tip end} end
Target=Target or {}
function Target:SendUpdateVipInfoMsg() rec("vipinfo") end
function DataPool:GetMatBag_Num() return 3 end
CaiLiaoCompound_Env={this=shown(true),CaiLiaoCompound_List={SetItemSelectByItemID=function(self,id) rec("select",id) end}}
function Player:GetAttackAttr() return {{index=3},{index=1}} end
function Player:GetFiveElementsIndexCanDoCohesion() return 1 end
function Player:GetFiveElements_ElementsLevel(i) return 25 end
function ComposeItem_Begin(id,n,x) rec("compose",id,n,x) end
local wuhunBag={[2]=boxItem(31,"御瑶盘"),[4]=boxItem(32,"琉璃焰"),[5]=boxItem(33,"其它")}
function useWuhunBag() realWuhunEnum=PlayerPackage.EnumItem PlayerPackage.EnumItem=function(self,k,i) if k=="base" then return wuhunBag[i] or boxItem(0,"") end return realWuhunEnum(self,k,i) end end
function restoreWuhunBag() PlayerPackage.EnumItem=realWuhunEnum end
function PlayerPackage:GetBagKfsData(i,k) if k=="EXTRALEVEL" then return i end end
function DataPool:GetPlayerMission_Memo(i) return "#{SQXY_09061_4}","任务描述{#G洛阳,201,88,0,赵捕头}" end
ZhongXiaItem_Env={ZhongXiaItem_Button1={GetProperty=function(self,k) return "False" end},ZhongXiaItem_Button2={GetProperty=function(self,k) return "True" end}}
function LifeAbility:Get_Equip_TableIndex(i) if i==1 or i==3 then return 5 end return -1 end
function LifeAbility:Get_Equip_Point(i) if i==3 then return 0 end return 7 end
BieYeFurniture={IsBieYeScene=function(self) return true end}
local function textBox(t) return {GetText=function() return t end} end
Examination_Env={this=shown(true),Examination_Text=textBox("问题"),Examination_Button_1=textBox("甲"),Examination_Button_2=textBox("乙"),Examination_Button_3=textBox("丙"),Examination_Button_4=textBox(""),Examination_Button_5=textBox("")}
BieYeUI={GetBieYeBaseInfo=function(self,kind,i) if kind=="ProductInfo" then return i+1,600 end if kind=="GardnerInfo" then if i==0 or i==3 then return 2 end return 0 end end,AskBieYeBaseInfo=function(self,n) rec("askbieye",n) end}
WuhunQuest_Env.WuhunQuest_InfoWindow={GetText=function() return "是否花费元宝播撒" end}
City={AskEnemyList=function(self,k) rec("ask",k) end,GetEnemyNum=function(self,k) return 1 end,EnumCityEnemy=function(self,k,i,f) if k==1 then return 77 end return 5 end,OpenAddEnemyDlg=function(self,s,id) rec("addenemy",s,id) end}
local function act(id,name) return {GetID=function() return id end,GetName=function() return name end} end
function GetHuoYueShopTotalCount(s) return 2 end
function GetHuoYueShopDaiBiInfo() return 100,50 end
function GetHuoYueShopData(s,j,n) return {{itemid=7,itemnum=1,daibitype=1,daibinum=10,limitday=0,limitweek=0,limitmonth=0,limitfov=0},{itemid=8,itemnum=1,daibitype=2,daibinum=5,limitday=3,limitday_self=2,limitweek=0,limitmonth=0,limitfov=0}} end
function HuoYueShopCalcMaxNumCanBuy(id,num,shop,have,cost,lim,limnum,x) if lim==1 then return limnum end return math.floor(have/cost) end
function DataPool:Lua_GetItemNameByIndex(id) if id==7 then return "代币物" end return "限购物" end
City.GetWeekDuanWei=function(self) return 1 end
City.GetHonourShopItemNum=function(self,lv) return 1 end
City.GetHonourShopInfo=function(self,i,k) if k=="remainnum" then return 5 end return 30 end
City.EnumHonourShop=function(self,i) return act(1,"战功物") end
City.DoHonourShopBuy=function(self,i,n) rec("honour",i,n) end
GoldRecycle_GiftShop_Env={this=shown(true),GoldRecycle_GiftShop_Item1_Info=textBox("甲"),GoldRecycle_GiftShop_Item2_Info=textBox("乙"),GoldRecycle_GiftShop_Item3_Info=textBox("丙"),
  GoldRecycle_GiftShop_Choose=function(i) rec("choose",i) end,GoldRecycle_GiftShop_GetClick=function() rec("getclick") end}
hdBag={boxItem(0,""),boxItem(31,"活动宝箱")}
function useHdBag() realHdEnum=PlayerPackage.EnumItem PlayerPackage.EnumItem=function(self,k,i) return hdBag[i+1] end end
function restoreHdBag() PlayerPackage.EnumItem=realHdEnum end
function Lua_GetSecKillFuBenCount_HuoDong() return 2 end
function EnumSecKillTable_HuoDong(i) return 1+i,"icon","活动甲",0,10,5,0,0,0,3,1,0,0,0,0,100003,7,70+i end
function LuaGetSeckillCampaignTableNew_HuoDong(a) rec("campaign",a) return 1,2 end
local function awakeList(t) return {GetItemNumber=function() return table.getn(t) end,GetItem=function(self,i) return t[i] end,SetItemSelect=function(self,i) rec("select",i) end} end
BieYePetBar_Awake_Env={this=shown(true),BieYePetBar_Awake_List01=awakeList({"小白?可觉醒"}),BieYePetBar_Awake_List02=awakeList({}),
  BieYePetBar_Awake_List_Selected=function(i) rec("selected",i) end,BieYePetBar_Awake_PetList_Input_Click=function(i) rec("input",i) end}
function DataPool:GetZongMenTalentNormalData(i,k) if k=="SectId" then return 500+i end end
function Player:Lua_AskSectOper(a,b) rec("sect",a,b) end
local realEnumAction=EnumAction
function EnumAction(i,k) if k=="boothitem" then if i==2 then return action(51,"金创药",1) end return action(0,"",0) end return realEnumAction(i,k) end
NpcShop={BulkBuyItem=function(self,i,n,x) rec("bulkbuy",i,n,x) end}
local function equipAction(id,name,dur,def,left) return {GetID=function() return id end,GetName=function() return name end,GetEquipDur=function() return dur end,
  GetDefineID=function() return def end,GetRemainRepairCount=function() return left end} end
local realEnumAction2=EnumAction
function EnumAction(i,k) if k=="equip" then if i==1 then return equipAction(55,"帽子甲",0.05,1001,2) end if i==2 then return equipAction(56,"衣服甲",0.9,1002,3) end
  return equipAction(0,"",1,-1,3) end return realEnumAction2(i,k) end
function DataPool:GetKfsData(k) if k=="NAME" then return "武魂甲" end if k=="LIFE" then return 10 end if k=="MAXLIFE" then return 100 end end
Shop_Env={this=shown(true)}
repairBag={boxItem(0,""),boxItem(41,"润物露"),boxItem(42,"润物露"),boxItem(43,"武魂延寿丹"),boxItem(44,"旧衣服")}
function useRepairBag() realRepairEnum=PlayerPackage.EnumItem realRepairBind=GetItemBindStatus PlayerPackage.EnumItem=function(self,k,i) return repairBag[i+1] end
  GetItemBindStatus=function(i) if i==2 or i==4 then return 1 end return 0 end end
function restoreRepairBag() PlayerPackage.EnumItem=realRepairEnum GetItemBindStatus=realRepairBind end
function Player:GetXiuLianMiJiInfo(i,k) local t={JingJie=2,Level=3,MaxLevel=9,UpLevelNeedMoney=100,UpLevelNeedExp=50+i} return t[k] end
local realEnumAction3=EnumAction
function EnumAction(i,k) if k=="xinfa" then if i==0 then return action(81,"心法甲",1) end if i==1 then return action(82,"心法乙",1) end return action(0,"",0) end return realEnumAction3(i,k) end
LifeAbility=LifeAbility or {}
function LifeAbility:GetLifeAbility_Number(id) return id+100 end
function Player:GetXinfaInfo(id,k) if k=="level" then return 40 end end
function GetUplevelXinfaSpendMoney(id,lv) if id==181 then return 15000 end return 90000 end
function GetUplevelXinfaSpendExp(id,lv) return 0 end
function SkillsStudyFrame_study(id) rec("study",id) end
djBag={boxItem(0,""),boxItem(51,"点金玉"),boxItem(52,"3级棉布"),boxItem(53,"点金玉")}
lwBag={boxItem(0,""),boxItem(61,"龙纹甲"),boxItem(62,"龙纹乙"),boxItem(63,"龙纹玉灵"),boxItem(64,"铸纹血玉"),boxItem(65,"杂物")}
gemBase={boxItem(0,""),boxItem(0,""),boxItem(71,"宝石雕琢符3级"),boxItem(0,""),boxItem(72,"宝石雕琢符3级")}
function useBag(t,bound) realUseEnum=PlayerPackage.EnumItem realUseBind=GetItemBindStatus
  PlayerPackage.EnumItem=function(self,k,i) if k=="material" then if i==0 then return boxItem(81,"红宝石(3级)") end return boxItem(0,"") end return t[i+1] end
  GetItemBindStatus=function(i) if bound[i] then return 1 end return 0 end end
function restoreUseBag() PlayerPackage.EnumItem=realUseEnum GetItemBindStatus=realUseBind end
function PlayerPackage:GetBagItemNum(i) return 1 end
function DataPool:LuaFnGetXingZhen_YingXiongNum() return 2 end
function DataPool:LuaFnGetXingZhen_YingXiongInfo(id,k) if k=="Name" then if id==2 then return "乔峰" end return "段誉" end if k=="Interests" then return 7,8 end end
function DataPool:LuaFnGetXingZhen_YingXiongHaoganLevel(id) return 500 end
function DataPool:LuaFnGetXingZhen_InterestsInfo(k,f) if f=="Name" then if k==8 then return "女儿红" end return "剑谱" end if f=="MaxLevel" then return 3 end end
function DataPool:LuaFnGetXingZhen_InterestsTotalGiveNum(k) if k==7 then return 30 end return 5 end
function PlayerPackage:IsBagItemLW(i) if i==1 or i==2 then return 1 end return 0 end
function PlayerPackage:GetBagLWData(i,k) if i==1 then return 5 end return 1 end
function PlayerPackage:IsLock(i) return 0 end
function PlayerPackage:GetItemTableIndex(i) if i==3 then return 38002107 end if i==4 then return 38000152 end return 0 end
function PlayerPackage:Lw_Op_Do(op,a,b,c) rec("lwop",op,a,b,c) end
local realPackageEnum=PlayerPackage.EnumItem
function PlayerPackage:EnumItem(kind,i) if kind=="material" then if i==1 then return boxItem(21,"中级勾天彩") end return boxItem(0,"") end return realPackageEnum(self,kind,i) end
)LUA";
static std::string utf8(const std::string &local){wchar_t wide[600]{};MultiByteToWideChar(936,0,local.c_str(),-1,wide,599);char out[1800]{};WideCharToMultiByte(CP_UTF8,0,wide,-1,out,1799,nullptr,nullptr);return out;}
static std::string gbk(const wchar_t *text){const int n=WideCharToMultiByte(936,0,text,-1,nullptr,0,nullptr,nullptr);std::string out(size_t(n>0?n:1),'\0');WideCharToMultiByte(936,0,text,-1,out.data(),n,nullptr,nullptr);out.resize(std::strlen(out.c_str()));return out;}
int wmain(int argc,wchar_t **argv){
    if(argc!=3)return 2;
    auto dll=LoadLibraryExW(argv[1],nullptr,LOAD_LIBRARY_SEARCH_DLL_LOAD_DIR|LOAD_LIBRARY_SEARCH_DEFAULT_DIRS);if(!dll)return 3;
    using Create=void *(*)(bool,bool);using State=void *(*)(void*);using Destroy=void (*)(void*);using Index=void (*)(void*,int);
    using Constructor=void (*)(void*,void*,int);using Run=int (*)(void*,const char*);
    auto create=api<Create>(dll,"?Create@LuaState@LuaPlus@@SAPEAV12@_N0@Z");auto native=api<State>(dll,"?GetCState@LuaState@LuaPlus@@QEAAPEAUlua_State@@XZ");
    auto destroy=api<Destroy>(dll,"?Destroy@LuaState@LuaPlus@@SAXPEAV12@@Z");auto table=api<void (*)(void*)>(dll,"lua_newtable");
    auto setTop=api<Index>(dll,"lua_settop");auto getTop=api<int (*)(void*)>(dll,"lua_gettop");auto number=api<void (*)(void*,double)>(dll,"lua_pushnumber");
    auto ctor=api<Constructor>(dll,"??0LuaObject@LuaPlus@@QEAA@PEAVLuaState@1@H@Z");auto dtor=api<Destroy>(dll,"??1LuaObject@LuaPlus@@QEAA@XZ");
    auto run=api<Run>(dll,"lua_dostring");auto text=api<const char *(*)(void*,int)>(dll,"lua_tostring");auto numberAt=api<double (*)(void*,int)>(dll,"lua_tonumber");
    auto openBase=api<int (*)(void*)>(dll,"luaopen_base");auto openTable=api<int (*)(void*)>(dll,"luaopen_table");auto openString=api<int (*)(void*)>(dll,"luaopen_string");
    if(!create||!native||!destroy||!table||!setTop||!getTop||!number||!ctor||!dtor||!run||!text||!numberAt||!openBase||!openTable||!openString)return 4;
    void *owner=create(false,false);if(!owner)return 5;void *vm=native(owner);
    openBase(vm);openTable(vm);openString(vm);setTop(vm,0);
    if(auto openMath=api<int (*)(void*)>(dll,"luaopen_math")){openMath(vm);setTop(vm,0);}
    table(vm);alignas(16) unsigned char object[80]{};ctor(object,owner,1);setTop(vm,0);
    int failures=0,checks=0;std::string first;
    auto fail=[&](const std::string &what){++failures;if(first.empty())first=what;};
    if(run(vm,gbk(fakeGame).c_str())!=0){fail("fake environment did not load");}
    setTop(vm,0);for(int i=0;i<500;++i)number(vm,double(i));const int before=getTop(vm);
    auto log=[&]{std::string out;if(run(vm,"return table.concat(calls,'|')")==0&&text(vm,-1))out=text(vm,-1);setTop(vm,before);run(vm,"calls={}");setTop(vm,before);return out;};
    auto call=[&](uint32_t id,gameplay::SnippetArgs a,const wchar_t *expectLog,double expectFirst,const wchar_t *expectText=nullptr,bool expectOk=true){
        ++checks;LuaResult result;bool issued=false;wchar_t detail[97]{};
        const bool ok=runGameSnippet(dll,object,id,a,result,issued,detail);
        const auto calls=log();char name[24];std::snprintf(name,24,"snippet %u",id);
        if(ok!=expectOk){char reason[300]{};WideCharToMultiByte(CP_UTF8,0,detail,-1,reason,299,nullptr,nullptr);fail(std::string(name)+" status "+reason);return;}
        if(getTop(vm)!=before){fail(std::string(name)+" stack");return;}
        if(!ok)return;
        if(calls!=gbk(expectLog))fail(std::string(name)+" calls: "+utf8(calls));
        if(result.numbers[0]!=expectFirst)fail(std::string(name)+" first result");
        if(expectText&&gbk(expectText)!=result.text)fail(std::string(name)+" text: "+utf8(result.text));
    };
    auto args=[](std::initializer_list<int> ints,std::initializer_list<double> reals={},const wchar_t *t=L""){gameplay::SnippetArgs a;int i=0;for(int v:ints)a.ints[i++]=v;i=0;for(double v:reals)a.reals[i++]=v;std::wcsncpy(a.text,t,48);return a;};
    call(gameplay::CombatSkill,args({},{},L"横扫"),L"",3);
    call(gameplay::CombatName,args({10}),L"",1,L"副本怪物");
    call(gameplay::CombatCast,args({3,10,101,-1},{64,64,45}),L"select,101|attack",1);
    call(gameplay::CombatCast,args({3,10,101,3},{64,64,45},L"横扫"),L"select,101|set,301|store|set,9",1);
    run(vm,"skillEnabled=0");setTop(vm,before);
    call(gameplay::CombatCast,args({3,10,101,3},{64,64,45},L"横扫"),L"select,101",0);
    run(vm,"skillEnabled=1");setTop(vm,before);
    run(vm,"cooldown=1");setTop(vm,before);
    call(gameplay::CombatCast,args({3,10,101,3},{64,64,45},L"横扫"),L"",0);
    run(vm,"cooldown=0");setTop(vm,before);
    call(gameplay::CombatCast,args({3,10,101,3},{64,64,45},L"错误名称"),L"",-2);
    call(gameplay::CombatCast,args({3,10,999,-1},{64,64,45}),L"select,999",-3);
    run(vm,"actionReady=false");setTop(vm,before);
    call(gameplay::CombatCast,args({3,10,101,-1},{64,64,45}),L"",0);
    run(vm,"actionReady=true;oldAction=Packet_Env.Packet_Space_Line10_Row10_button.DoAction;Packet_Env.Packet_Space_Line10_Row10_button.DoAction=function() error('fixture rejection') end");setTop(vm,before);
    call(gameplay::CombatCast,args({3,10,101,3},{64,64,45},L"横扫"),L"",0,nullptr,false);
    if(run(vm,"return buttonAction")!=0||numberAt(vm,-1)!=9)fail("Combat action button not restored after error");setTop(vm,before);
    run(vm,"Packet_Env.Packet_Space_Line10_Row10_button.DoAction=oldAction;oldButton=Packet_Env.Packet_Space_Line10_Row10_button;Packet_Env.Packet_Space_Line10_Row10_button=nil");setTop(vm,before);
    call(gameplay::CombatCast,args({3,10,101,3},{64,64,45},L"横扫"),L"",0,nullptr,false);
    run(vm,"Packet_Env.Packet_Space_Line10_Row10_button=oldButton");setTop(vm,before);
    call(gameplay::RunTo,args({2},{258,154}),L"run,258,154,2",1);
    call(gameplay::TalkNpc,args({2},{258,154},L"何所思"),L"run,258,154,2|npc,何所思",1);
    call(gameplay::NpcTarget,args({},{},L"巴盖里"),L"npc,巴盖里",1);
    call(gameplay::QuestOptions,args({}),L"",1,L"#{JYQQ_250801_02}\n波斯玫瑰兑换奖励\n#{JYQQ_250801_15}\n");
    call(gameplay::QuestOption,args({1},{},L"#{JYQQ_250801_02}"),L"option,0,800001,7",1,L"#{JYQQ_250801_02}");
    call(gameplay::QuestOption,args({0},{},L"兑换奖励"),L"option,1,800001,8",1);
    call(gameplay::QuestOption,args({1},{},L"兑换奖励"),L"",0);
    call(gameplay::QuestOption,args({1},{},L"领取经验纳元"),L"option,3,800002,9",1);
    call(gameplay::QuestButton,args({1,0}),L"accept",1);
    call(gameplay::QuestButton,args({2,0}),L"continue",1);
    call(gameplay::QuestButton,args({3,0}),L"",0,L"继续");
    run(vm,gbk(L"buttonText='完成'").c_str());setTop(vm,before);
    call(gameplay::QuestButton,args({3,0}),L"complete,0|hide",1);
    call(gameplay::QuestOption,args({0},{},L"兑换"),L"",0);
    call(gameplay::BagCount,args({},{},L"波斯玫瑰"),L"",35);
    run(vm,"questVisible=true");setTop(vm,before);
    call(gameplay::NpcEventItem,args({1}),L"",1,L"波斯玫瑰兑换奖励");
    call(gameplay::NpcEventItem,args({9}),L"",0,L"");
    call(gameplay::NpcEventAll,args({}),L"",4,L" #{JYQQ_250801_02} 波斯玫瑰兑换奖励 说明 #{JYQQ_250801_15} ");
    call(gameplay::GuildInfo,args({}),L"",12,L"测试城");
    call(gameplay::ActiveBox,args({}),L"",3);
    run(vm,"useBoxBag()");setTop(vm,before);
    call(gameplay::UseBagItem,args({0,0,0}),L"use,0",0);
    call(gameplay::UseBagItem,args({0,2,1}),L"use,2",2);
    call(gameplay::UseBagItem,args({0,1,1}),L"use,0",0);
    call(gameplay::UseBagItem,args({1,0,1}),L"",-1);
    run(vm,"restoreBag()");setTop(vm,before);
    call(gameplay::MissionFind,args({},{},L"#{SQXY_09061_4}"),L"",4);
    call(gameplay::MissionVar,args({4,1}),L"",11);
    call(gameplay::MissionVar,args({3,1}),L"",-1);
    call(gameplay::PlayerState,args({}),L"",5);
    call(gameplay::OpenMonthlySign,args({}),L"monthly-open,1",1);
    call(gameplay::Dismount,args({},{},L"坐骑："),L"dispel,坐骑：",1);
    run(vm,"savedDismount=Player.DispelBuffByName;Player.DispelBuffByName=nil");setTop(vm,before);
    call(gameplay::Dismount,args({},{},L"坐骑："),L"",-1);
    run(vm,"GetMountID=function() return -1 end");setTop(vm,before);
    call(gameplay::Dismount,args({},{},L"坐骑："),L"",0);
    run(vm,"GetMountID=function() return 123 end");setTop(vm,before);
    call(gameplay::Dismount,args({},{},L"坐骑："),L"",-1);
    run(vm,"GetMountID=nil;Player.DispelBuffByName=savedDismount");setTop(vm,before);
    call(gameplay::DoubleTimer,args({}),L"",3600);
    call(gameplay::VipLevel,args({}),L"",5);
    call(gameplay::MsgBoxText,args({1}),L"msgbox",1);
    call(gameplay::MsgBoxText,args({0}),L"",0);
    run(vm,"MessageBox_Self_Env.MessageBox_Self_Text={GetText=function() return routeMessage end}");setTop(vm,before);
    call(gameplay::MsgBoxText,args({4}),L"msgbox",1);
    call(gameplay::MsgBoxText,args({1}),L"",0);
    call(gameplay::XingYunCount,args({}),L"",17);
    call(gameplay::VipRefresh,args({}),L"vipinfo",1);
    call(gameplay::QuitGame,args({}),L"quit,quit",1);
    call(gameplay::BagCountIn,args({1},{},L"中级勾天彩"),L"",1);
    call(gameplay::BagCountIn,args({2},{},L"波斯玫瑰"),L"",5);
    call(gameplay::BagCountIn,args({0},{},L"波斯玫瑰"),L"",0,nullptr,false);
    call(gameplay::ItemList,args({0},{},L"波斯"),L"",1,L"波斯玫瑰\t35\n");
    call(gameplay::ItemList,args({1},{},L"勾天彩"),L"",1,L"中级勾天彩\t1\n");
    call(gameplay::ItemList,args({2},{},L"玫瑰"),L"",1,L"波斯玫瑰\t5\n");
    call(gameplay::ItemList,args({3},{},L"玫瑰"),L"",1,L"波斯玫瑰\t40\n");
    call(gameplay::CompoundSelect,args({10002}),L"select,10002",1);
    call(gameplay::CompoundSelect,args({9999}),L"",0,nullptr,false);
    call(gameplay::AttackAttr,args({}),L"",3);
    call(gameplay::CohesionCost,args({}),L"",8);
    call(gameplay::LifeCompose,args({404}),L"compose,404,99,-1",1);
    call(gameplay::LifeCompose,args({399}),L"",0,nullptr,false);
    call(gameplay::BagSpace,args({1}),L"",2);
    run(vm,"useWuhunBag()");setTop(vm,before);
    call(gameplay::WuhunList,args({},{},L"御瑶盘 琉璃焰"),L"",2,L"2\t0\t2\n4\t1\t4\n");
    call(gameplay::WuhunCompound,args({2,4},{},L"御瑶盘 琉璃焰"),L"xs-clear|xs-name,OnWuHunCompoundNew|xs-script,790076|xs-param,0,2|xs-param,1,4|xs-param,2,1|xs-count,3|xs-send",1);
    call(gameplay::WuhunCompound,args({2,5},{},L"御瑶盘 琉璃焰"),L"",0);
    call(gameplay::WuhunCompound,args({2,2},{},L"御瑶盘 琉璃焰"),L"",0,nullptr,false);
    call(gameplay::WuhunList,args({},{},L"其它"),L"",0,nullptr,false);
    run(vm,"restoreWuhunBag()");setTop(vm,before);
    call(gameplay::MissionDesc,args({},{},L"#{SQXY_09061_4}"),L"",1,L"任务描述{#G洛阳,201,88,0,赵捕头}");
    call(gameplay::MissionDesc,args({},{},L"其它任务"),L"",0);
    call(gameplay::UiEnabled,args({0}),L"",1);
    call(gameplay::UiEnabled,args({1}),L"",0);
    call(gameplay::UiEnabled,args({2}),L"",0,nullptr,false);
    call(gameplay::EquipAdjust,args({}),L"xs-clear|xs-name,FinishAdjust|xs-script,809261|xs-param,0,3|xs-count,1|xs-send",1);
    call(gameplay::CityEnemyHas,args({77}),L"",1);
    call(gameplay::CityEnemyHas,args({9}),L"",0);
    call(gameplay::CityEnemyAsk,args({}),L"ask,0|ask,1",1);
    call(gameplay::OpenAddEnemy,args({9}),L"addenemy,BenFu,9",1);
    call(gameplay::BieYeScene,args({}),L"",1);
    call(gameplay::BieYeProduct,args({2}),L"",3);
    call(gameplay::BieYeProduct,args({5}),L"",0,nullptr,false);
    call(gameplay::BieYeAsk,args({}),L"askbieye,5",1);
    call(gameplay::BieYeGardeners,args({}),L"",1);
    run(vm,"wuhunHidden=WuhunQuest_Env.this WuhunQuest_Env.this={IsVisible=function() return true end}");setTop(vm,before);
    call(gameplay::WuhunText,args({0}),L"wuhun",1);
    call(gameplay::WuhunText,args({1}),L"",0);
    call(gameplay::ExamRead,args({}),L"",1,L"问题\t甲\t乙\t丙\t\t");
    run(vm,"Player.GetData=function(self,k) if k=='MILITARYEXCHANGE' then return 100 end if k=='YUANBAO' then return 1234 end if k=='MONEY' then return 20000 end return nil end");setTop(vm,before);
    call(gameplay::HuoYueBuy,args({2,4},{},L"代币物"),L"xs-clear|xs-name,BuyItem|xs-script,888393|xs-param,0,-1|xs-param,1,2|xs-param,2,7|xs-param,3,4|xs-count,4|xs-send",1);
    call(gameplay::HuoYueBuy,args({2,0},{},L"代币物"),L"",0);
    call(gameplay::HuoYueBuy,args({2,0},{},L"限购物"),L"xs-clear|xs-name,BuyItem|xs-script,888393|xs-param,0,-1|xs-param,1,2|xs-param,2,8|xs-param,3,2|xs-count,4|xs-send",1);
    call(gameplay::HuoYueBuy,args({1,-1},{},L"代币物"),L"xs-clear|xs-name,BuyItem|xs-script,888393|xs-param,0,-1|xs-param,1,1|xs-param,2,7|xs-param,3,10|xs-count,4|xs-send",1);
    call(gameplay::HuoYueBuy,args({3,-1},{},L"代币物"),L"",0,nullptr,false);
    call(gameplay::HonourBuy,args({-1},{},L"战功物"),L"honour,0,3",1);
    call(gameplay::HonourBuy,args({2},{},L"战功物"),L"honour,0,2",1);
    call(gameplay::HonourBuy,args({2},{},L"其它"),L"",0);
    call(gameplay::GoldGiftRead,args({}),L"",1,L"甲\t乙\t丙");
    call(gameplay::GoldGiftChoose,args({2}),L"choose,2|getclick",1);
    call(gameplay::GoldGiftChoose,args({4}),L"",0,nullptr,false);
    run(vm,"useHdBag()");setTop(vm,before);
    call(gameplay::UseBoxItem,args({},{},L"活动宝箱"),L"use,1",1);
    call(gameplay::UseBoxItem,args({},{},L"大宝箱"),L"",-1);
    call(gameplay::UseBoxItem,args({},{},L"其它"),L"",0,nullptr,false);
    run(vm,"restoreHdBag()");setTop(vm,before);
    call(gameplay::HuoDongCount,args({}),L"",2);
    call(gameplay::HuoDongEnum,args({0}),L"campaign,70",1,L"活动甲");
    call(gameplay::HuoDongEnum,args({64}),L"",0,nullptr,false);
    call(gameplay::AwakeRead,args({}),L"",1,L"1&小白?可觉醒 \t");
    call(gameplay::AwakeAdd,args({1,0,0}),L"select,0|selected,0",1);
    call(gameplay::AwakeAdd,args({2,0,1}),L"input,1",1);
    call(gameplay::AwakeAdd,args({3,0,0}),L"",0,nullptr,false);
    call(gameplay::SectOper,args({2}),L"sect,0,502",1);
    call(gameplay::SectOper,args({10}),L"",0,nullptr,false);
    call(gameplay::NpcShopBuy,args({0}),L"bulkbuy,2,1,0",2);
    call(gameplay::NpcShopBuy,args({1}),L"",-1);
    call(gameplay::NpcShopBuy,args({gameplay::count(gameplay::shopItems)}),L"",0,nullptr,false);
    run(vm,"WuhunQuest_Env.this=wuhunHidden");setTop(vm,before);
    call(gameplay::UseBagItem,args({gameplay::count(gameplay::usableItems),0,0}),L"",0,nullptr,false);
    call(gameplay::Dismount,args({},{},L"其它"),L"",0,nullptr,false);
    call(gameplay::PlayerData,args({2}),L"",1234);
    call(gameplay::PlayerData,args({1}),L"",-1);
    call(gameplay::TeamCount,args({}),L"",3);
    call(gameplay::XScript,args({5,3}),L"xs-clear|xs-name,GetPrize|xs-script,885577|xs-param,0,3|xs-count,1|xs-send",1);
    call(gameplay::XScript,args({4,1,0}),L"xs-clear|xs-name,MartialLastDayMonsterReward|xs-script,507010|xs-param,0,1|xs-param,1,0|xs-count,2|xs-send",1);
    call(gameplay::UiCall,args({0,4}),L"token,4",1);
    call(gameplay::UiCall,args({1,0}),L"",0);
    call(gameplay::UiCall,args({4,0}),L"msgbox",1);
    call(gameplay::UiCall,args({5,0}),L"",-1);
    call(gameplay::WindowVisible,args({},{},L"SafeCenter_SafeScore"),L"",1);
    call(gameplay::WindowVisible,args({},{},L"Missing_Window"),L"",0);
    call(gameplay::CloseAll,args({}),L"closeall",1);
    call(gameplay::UiEvent,args({0}),L"event,OPEN_SAFECENTER_SAFESCORE",1);
    call(gameplay::BankState,args({}),L"",1);
    call(gameplay::BankBig,args({}),L"event,TOGLE_BIGBANK,77|smallhide|which,1",1);
    call(gameplay::BankBig,args({}),L"",0);
    call(gameplay::BankMoney,args({1,150000}),L"bankget,100000",100000);
    call(gameplay::BankMoney,args({2,50000}),L"banksave,20000",20000);
    call(gameplay::BankItem,args({1},{},L"波斯玫瑰"),L"update,0|take,1,4",1);
    call(gameplay::BankItem,args({0},{},L"波斯玫瑰"),L"",0);
    call(gameplay::BagStore,args({},{},L"波斯玫瑰"),L"set,1|store|set,9",1);
    call(gameplay::BagStore,args({1},{},L"波斯玫瑰"),L"set,1|store|set,9",1);
    call(gameplay::BagStore,args({2},{},L"波斯玫瑰"),L"",0);
    call(gameplay::BagStore,args({3},{},L"波斯玫瑰"),L"",0,nullptr,false);
    call(gameplay::EquipDur,args({1,10}),L"",55,L"帽子甲");
    call(gameplay::EquipDur,args({2,10}),L"",56,L"");
    call(gameplay::EquipDur,args({22,10}),L"",0,nullptr,false);
    call(gameplay::EquipRepair,args({1,1}),L"xs-clear|xs-name,OnEquipRepairNew|xs-script,805027|xs-param,0,140|xs-param,1,1|xs-param,2,1|xs-param,3,-1|xs-param,4,1|xs-param,5,0|xs-count,6|xs-send",1);
    call(gameplay::EquipRepair,args({1,0}),L"xs-clear|xs-name,OnEquipRepairNew|xs-script,805027|xs-param,0,-1|xs-param,1,1|xs-param,2,1|xs-param,3,-1|xs-param,4,1|xs-param,5,1|xs-count,6|xs-send",1);
    call(gameplay::EquipRepair,args({1,2}),L"",0,nullptr,false);
    call(gameplay::WuhunLife,args({16}),L"",1,L"武魂甲");
    call(gameplay::WuhunLife,args({5}),L"",0);
    run(vm,"useRepairBag() buttonAction=9");setTop(vm,before);
    call(gameplay::EquipRestore,args({4,0}),L"xs-clear|xs-name,EquipFaileTimesOnEquip|xs-script,809265|xs-param,0,-1|xs-param,1,4|xs-param,2,2|xs-count,3|xs-send",2);
    call(gameplay::WuhunRepair,args({}),L"xs-clear|xs-name,Kfs_AddLifeNew|xs-script,809270|xs-param,0,1|xs-param,1,18|xs-param,2,3|xs-param,3,1|xs-param,4,1|xs-count,5|xs-send",3);
    call(gameplay::BagSell,args({2},{},L"旧衣服"),L"set,44|store|set,9",4);
    call(gameplay::BagSell,args({1},{},L"旧衣服"),L"",-3);
    run(vm,"restoreRepairBag() Shop_Env.this={IsVisible=function() return false end}");setTop(vm,before);
    call(gameplay::BagSell,args({0},{},L"波斯玫瑰"),L"",-1);
    call(gameplay::XiuLianInfo,args({1}),L"",2);
    call(gameplay::XiuLianInfo,args({21}),L"",0,nullptr,false);
    call(gameplay::XinfaRead,args({1}),L"",181);
    call(gameplay::XinfaRead,args({3}),L"",-1);
    call(gameplay::XinfaRead,args({9}),L"",0,nullptr,false);
    call(gameplay::XinfaStudy,args({2}),L"study,182",1);
    call(gameplay::XinfaStudy,args({3}),L"",0);
    run(vm,"useBag(djBag,{[3]=true})");setTop(vm,before);
    call(gameplay::DianJin,args({0,1,0}),L"xs-clear|xs-name,DianJin|xs-script,892944|xs-param,0,135|xs-param,1,2|xs-param,2,1|xs-param,3,1|xs-count,4|xs-send",1);
    call(gameplay::DianJin,args({1,1,0}),L"",0);
    call(gameplay::DianJin,args({3,1,0}),L"xs-clear|xs-name,DianJin|xs-script,892944|xs-param,0,135|xs-param,1,2|xs-param,2,3|xs-param,3,1|xs-count,4|xs-send",1);
    call(gameplay::DianJin,args({0,0,1}),L"",0);
    call(gameplay::DianJin,args({0,0,0}),L"",0,nullptr,false);
    run(vm,"restoreUseBag() useBag(gemBase,{[2]=true})");setTop(vm,before);
    call(gameplay::GemCarve,args({},{},L"红宝石(3级)"),L"xs-clear|xs-name,OnGemCarve|xs-script,800117|xs-param,0,100|xs-param,1,2|xs-param,2,135|xs-param,3,1|xs-param,4,1|xs-count,5|xs-send",1);
    call(gameplay::GemCarve,args({},{},L"蓝宝石(3级)"),L"",0);
    call(gameplay::GemCarve,args({},{},L"其它"),L"",0,nullptr,false);
    run(vm,"restoreUseBag() useBag(lwBag,{[2]=true}) buttonAction=9");setTop(vm,before);
    call(gameplay::LwScan,args({}),L"",0,L"1\t1\t5\t0\n2\t1\t1\t1\n3\t2\t1\t0\n4\t3\t38000152\t0\n");
    call(gameplay::LwUnequip,args({}),L"",1);
    call(gameplay::LwCombine,args({1,3,4}),L"lwop,1,1,3,4",1);
    call(gameplay::LwCombine,args({1,5,-1}),L"",0);
    call(gameplay::LwCombine,args({1,1,-1}),L"",0,nullptr,false);
    call(gameplay::LwEquip,args({2}),L"set,62|store|set,9",1);
    call(gameplay::LwEquip,args({3}),L"",0);
    // SelfTarget: the bridge fills the player's own ids; success only when the selected target is that player.
    call(gameplay::SelfTarget,args({10,101}),L"select,101",1);
    call(gameplay::SelfTarget,args({10,555}),L"select,555",0);
    run(vm,"restoreUseBag()");setTop(vm,before);
    call(gameplay::XZGift,args({1}),L"xs-clear|xs-name,OpenXZ3_GiveGift|xs-script,888052|xs-param,0,2|xs-param,1,2|xs-count,2|xs-send",1);
    call(gameplay::XZGift,args({0}),L"",0);
    call(gameplay::XZGift,args({14}),L"",0);
    call(gameplay::XZGift,args({gameplay::count(gameplay::xzGifts)}),L"",0,nullptr,false);
    call(gameplay::TempBag,args({0},{},L"许愿果 波斯玫瑰"),L"temp,2,Packet_Temporary",1);
    call(gameplay::TempBag,args({0},{},L"玫瑰"),L"",0);
    call(gameplay::TempBag,args({1}),L"tempall",1);
    call(gameplay::SweepCount,args({}),L"",3);
    call(gameplay::SweepEnum,args({1}),L"",5,L"少室山");
    {++checks;LuaResult result;bool issued=false;wchar_t detail[97]{};
        if(!runGameSnippet(dll,object,gameplay::SweepEnum,args({1}),result,issued,detail)||result.numbers[5]!=2||issued||getTop(vm)!=before)
            fail("sweep remaining count was not returned as a read-only numeric result");}
    call(gameplay::SweepData,args({}),L"",0);
    call(gameplay::SweepOpenPage,args({41}),L"openpage,41,0",1);
    call(gameplay::SweepBoss,args({}),L"boss,2",2);
    call(gameplay::CloseNamed,args({0}),L"close,SweepPage,true",1);
    call(gameplay::ShopMoney,args({50000}),L"apply,draw_ok,30000",30000);
    call(gameplay::GemList,args({0}),L"",2,L"红宝石（1级）\t0\t4\t1\n红宝石（1级）\t1\t2\t1\n");
    call(gameplay::GemList,args({1}),L"",1,L"黄宝石（2级）\t-1\t5\t2\n");
    call(gameplay::GemList,args({2}),L"",0);
    call(gameplay::GemCombine,args({0,5,1},{},L"红宝石（1级）"),L"combine,3,5,0,100",1);
    call(gameplay::GemCombine,args({1,4,1},{},L"红宝石（1级）"),L"combine,4,5,1,75",1);
    call(gameplay::GemCombine,args({2,3,1},{},L"红宝石（1级）"),L"combine,3,5,2,50",1);
    call(gameplay::GemCombine,args({0,5,2},{},L"红宝石（1级）"),L"",-3);
    call(gameplay::GemCombine,args({1,5,1},{},L"黄宝石（2级）"),L"",-2);
    call(gameplay::GemCombine,args({0,6,1},{},L"红宝石（1级）"),L"",0,nullptr,false);
    call(gameplay::BankMoney,args({1,0}),L"",0,nullptr,false);
    call(gameplay::TempBag,args({1},{},L"x"),L"",0,nullptr,false);
    call(gameplay::CloseNamed,args({gameplay::count(gameplay::closableWindows)}),L"",0,nullptr,false);
    // Out-of-range or non-whitelisted arguments never reach the VM.
    call(gameplay::XScript,args({5,9}),L"",0,nullptr,false);
    call(gameplay::UiCall,args({0,9}),L"",0,nullptr,false);
    call(gameplay::WindowVisible,args({},{},L"Bad Window"),L"",0,nullptr,false);
    // A missing game function fails inside pcall; an action reports a possibly issued call.
    run(vm,"AutoRunToTargetEx=nil");setTop(vm,before);
    {++checks;LuaResult result;bool issued=false;wchar_t detail[97]{};const bool ok=runGameSnippet(dll,object,gameplay::RunTo,args({0},{1,1}),result,issued,detail);
        if(ok||!issued||getTop(vm)!=before)fail("missing game function was not reported as uncertain");}
    for(int i=0;i<before&&!failures;++i)if(numberAt(vm,i+1)!=i)fail("parent stack changed");
    // New direct-call path: same official SDK, persistent child, arbitrary trusted Lua text.
    try{
        resident::GameTextSession session(dll,object);
        auto check=[&](bool ok,const char *why){++checks;if(!ok)fail(why);};
        auto values=session.evaluate("return 42,'直调中文',nil,true","",4);
        check(session.evaluate("return GetCampaignTotalNum(301)","n",1)[0].number==3,"Direct Lua campaign total");
        check(values.size()==4&&values[0].number==42&&values[1].text=="直调中文"&&values[2].kind==resident::Value::Nil&&values[3].kind==resident::Value::Boolean&&values[3].number==1,"Direct Lua scalar/result positions");
        session.evaluate("taskPrivate=317;function NewlyAddedFunction(a) return a+taskPrivate end","",0);
        check(session.evaluate("return NewlyAddedFunction(43)","n",1)[0].number==360,"New function required a whitelist");
        check(session.evaluate("return 0.375","l",1)[0].number==0.375,"Original floating-point format lost precision");
        {auto flags=session.evaluate("return 0,1,false,true","bbbb",4);
            check(flags.size()==4&&!flags[0].number&&flags[1].number&&!flags[2].number&&flags[3].number,"Numeric zero became a truthy boolean");}
        {bool rejected=false;try{session.evaluate("return nil","b",1);}catch(const std::exception&){rejected=true;}
            check(rejected,"Unknown boolean result was fabricated as false");}
        check(session.evaluate("return string.rep('x',4096)","s",1)[0].text.size()==4096,"Direct result retained the old 512-byte cap");
        check(session.evaluate("return type(table)","s",1)[0].text=="table","Game global fallback missing");
        session.evaluate("local e={LocalAction=function() return 19 end};setmetatable(_G,{__index=e})","",0);
        check(session.evaluate("return LocalAction(),type(table)","ns",2)[0].number==19,"Window environment fallback failed");
        for(const char *source:{"this is not Lua!","error('fixture direct error')","while true do end","return string.rep('x',65537)"}){
            bool rejected=false;try{session.evaluate(source,"s",1);}catch(const std::exception&){rejected=true;}check(rejected,"Direct Lua error/budget/return bound not enforced");
            check(getTop(vm)==before,"Direct Lua changed parent stack on error");
        }
        check(session.evaluate("return 27","n",1)[0].number==27,"Direct Lua did not recover after error");
        {resident::GameTextSession other(dll,object);check(other.evaluate("return taskPrivate","",1)[0].kind==resident::Value::Nil,"Tasks shared their private game Lua globals");}
        check(run(vm,"return taskPrivate")==0&&text(vm,-1)==nullptr,"Direct Lua polluted parent game globals");setTop(vm,before);
    }catch(const std::exception &e){fail(std::string("Direct SDK session: ")+e.what());}
    dtor(object);destroy(owner);FreeLibrary(dll);
    FILE *report=_wfopen(argv[2],L"wb");if(!report)return 6;
    std::string escaped;for(char c:first){if(c=='"'||c=='\\')escaped+='\\';if(c=='\n'){escaped+="\\n";continue;}escaped+=c;}
    std::fprintf(report,"{\"status\":\"%s\",\"checks\":%d,\"failures\":%d,\"first_failure\":\"%s\",\"lua_runtime\":\"LuaPlus.dll Lua 5.0\",\"game_process_accessed\":false}\n",failures?"fail":"pass",checks,failures,escaped.c_str());
    std::fclose(report);return failures?1:0;
}
