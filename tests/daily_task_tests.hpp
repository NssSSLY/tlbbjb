#pragma once
#include "game_lua_actions.hpp"
#include "game_text_session.hpp"
#include "resident_client.hpp"
#include "flow_runner.hpp"
#include "task_completion.hpp"
#include "resident_tests.hpp"
#include <QFile>
#include <QDateTime>
#include <QDir>
#include <QJsonDocument>
#include <stdexcept>
namespace tlbb {
// The parent is a fixture-owned LuaPlus state, not the user's Game.exe.
static const char *dailyFakeGame=R"LUA(
W={quest=false,dialog='root',kind='shitu',done=false,played=false,visible=false,claims=0,joins=0,rewards=0,
 gem=0,material=0,yellow=0,jade=100,debug='',limit=false,limitOnSubmit=false,limitAfter=0,noeffect=false,noDialog=false,heads=0}
local function a(id,name,n) return {GetID=function() return id end,GetName=function() return name end,GetNum=function() return n end} end
function AutoRunToTargetEx() end
function SetAutoRunTargetNPCName(name) W.quest=not W.noDialog W.dialog='root' end
function CloseAllWindow() W.quest=false W.visible=false end
Quest_Env={this={IsVisible=function() return W.quest end,Hide=function() W.quest=false end}}
DataPool={}
function DataPool:GetBaseBag_Num() if W.unreadableBag then return -1 end return 3 end
function DataPool:GetMatBag_Num() return 1 end
function DataPool:GetNPCEventList_Num() if W.kind=='gulanyu' and W.dialog=='gems' then return 3 end return 2 end
function DataPool:GetNPCEventList_Item(i)
 if i==0 then
  local t='请选择'
  if W.kind=='shitu' and W.done then t='对不起，你今天已经参加过此活动了，请明天再来!' end
  if W.kind=='xingyun' and W.played then t='你今天已经参加过幸运快活三' end
  if W.kind=='xingyun' and W.cooldown then t='请再等60分钟后参加' end
  if W.kind=='xingyun' and W.rewards>0 then t='#{XYLP_20071222_02}' end
  if W.kind=='gulanyu' and W.limit then t='你今天累计兑换了10颗宝石，已达上限' end
  return 'text',0,0,0,t
 end
 local t='师徒心连心'
 if W.kind=='xingyun' then if W.played then t='领取幸运快活三奖励' else t='幸运快活三' end end
 if W.kind=='gulanyu' then if W.dialog=='gems' then if i==2 then t='黄玉（1级）' else t='红宝石（1级）' end else t='#{FZYH_170213_7}' end end
 return 'id',0,123,1,t
end
function QuestFrameOptionClicked(i,script,extra)
 local k,a,b,c,t=DataPool:GetNPCEventList_Item(i)
 if t=='师徒心连心' then W.claims=W.claims+1 if not W.noeffect then W.done=true end
 elseif t=='幸运快活三' then W.joins=W.joins+1 if not W.noeffect then W.visible=true W.quest=false end
 elseif t=='领取幸运快活三奖励' then W.rewards=W.rewards+1
 elseif t=='#{FZYH_170213_7}' then W.dialog='gems'
 elseif t=='红宝石（1级）' or t=='黄玉（1级）' then
  W.claims=W.claims+1
  if W.limitOnSubmit then W.limit=true W.debug='你今天累计兑换了10颗宝石，不能继续兑换'
  elseif not W.noeffect then
   if t=='黄玉（1级）' then W.yellow=W.yellow+1 else W.gem=W.gem+1 end
   W.jade=W.jade-3 W.debug='兑换成功'
   if W.limitAfter>0 and W.claims>=W.limitAfter then W.limit=true W.debug='你今天累计兑换了10颗宝石，已达上限' end
  end
 end
end
function GetDictionaryString(key)
 if key=='FZYH_170213_7' then return '古兰玉兑换宝石' end
 if key=='FZYH_170213_28' then return '兑换成功' end
 if key=='ResultText_15' then return '背包已满' end
 return '#{'..key..'}'
end
PlayerPackage={}
function PlayerPackage:EnumItem(kind,i)
 if kind=='base' and i==0 then return a(100,'古兰玉',W.jade) end
 if kind=='base' and i==1 then return a(W.gem>0 and 101 or 0,'红宝石(1级)',W.gem) end
 if kind=='base' and i==2 then return a(W.yellow>0 and 103 or 0,'黄玉(1级)',W.yellow) end
 if kind=='material' and i==0 then return a(W.material>0 and 102 or 0,'红宝石（1级）',W.material) end
 return a(0,'',0)
end
Bank={EnumTemItem=function() return a(0,'',0) end}
Player={GetState=function() return 0 end}
XingYun_Env={this={IsVisible=function() return W.visible end},
 Play_Ani=function(i) W.heads=W.heads+1 end,
 XingYun_Close=function() W.visible=false W.played=true end}
for i=1,20 do XingYun_Env['XingYun_Head'..i]={GetToolTip=function() if W.heads>0 then return '' end return '未翻' end} end
)LUA";
struct DailySdkHost:resident::Host{
    HMODULE dll;void *registration;resident::GameTextSession &text;QString kind;int scene=2;double x=139,y=132;bool allowSpend=true;
    QString result,logs;int motions=0;
    DailySdkHost(HMODULE d,void *r,resident::GameTextSession &t,QString k):dll(d),registration(r),text(t),kind(std::move(k)){
        if(kind=="xingyun"){scene=1;x=230;y=350;}if(kind=="gulanyu"){scene=0;x=280;y=320;}
    }
    resident::Values evaluate(const std::string &s,const std::string &f,int n)override{return text.evaluate(s,f,n);}
    resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a)override{
        using resident::Value;using resident::Values;
        if(id==gameplay::DebugMessages){auto s=text.evaluate("return W.debug","s",1);return {Value(1),Value(0),s[0]};}
        if((gameplay::snippetRisk(id,a)&gameplay::RiskSpend)&&!allowSpend)throw std::runtime_error("allow_spend is off");
        if(id==gameplay::RunTo){++motions;scene=a.ints[0];x=a.reals[0];y=a.reals[1];}
        game_lua::LuaResult out;bool issued=false;wchar_t detail[97]{};
        if(!game_lua::runGameSnippet(dll,registration,id,a,out,issued,detail))throw std::runtime_error(QString::fromWCharArray(detail).toStdString());
        Values values;for(int i=0;i<out.count;++i)values.emplace_back(out.numbers[i]);
        if(id==gameplay::BagCount||id==gameplay::BagCountIn||id==gameplay::QuestOption)
            logs+=QString("sdk[%1] %2 => %3\n").arg(id).arg(QString::fromWCharArray(a.text)).arg(out.numbers[0]);
        // Exactly the production wire shape, including its string-slot placeholder.
        if(out.text[0])values.emplace_back(resident::convert(out.text,936,CP_UTF8));
        return values;
    }
    resident::Values call(const std::string &op,const std::string &v)override{
        using resident::Value;
        if(op=="position")return {Value(true),Value(scene),Value(x),Value(y),Value(kind.toStdString())};
        if(op=="task_result"){result=QString::fromStdString(v);return {};}
        if(op=="stop_motion")return {};
        throw std::runtime_error("Unexpected daily fixture host call");
    }
    std::vector<resident::Object> objects()override{return {};}
    void log(const std::string &s)override{logs+=QString::fromStdString(s)+'\n';}
};
template<class Test>void dailyTaskTests(const QString &root,const QString &temporary,Test test){
    auto must=[](bool v,const char *why){if(!v)throw std::runtime_error(why);};
    test("task_lifecycle_requires_precheck_and_verified_terminal_receipt",[&]{
        struct Fake:ResidentFake{
            QString receipt;
            resident::Values call(const std::string &op,const std::string &value)override{
                if(op=="task_result"){receipt=QString::fromStdString(value);return {};}
                return ResidentFake::call(op,value);
            }
        };
        const auto entry=temporary+"/checked-task.lua";QFile f(entry);must(f.open(QIODevice::WriteOnly),"Lifecycle fixture unavailable");
        f.write("return {check=function(c) if c.already then return 'already_done','already' end if c.blocked then return 'unknown','cannot read' end return 'ready' end,"
                "run=function() PushDebugMessage('fixture_action') end,verify=function(c) if c.bad then return 'unknown','completion unavailable' end return 'done','confirmed' end}");f.close();
        for(int i=0;i<4;++i){
            Fake host;QJsonObject config{{"already",i==0},{"blocked",i==2},{"bad",i==3}};QString why;
            const auto source=prepareResidentScript(root+"/scripts/legacy",entry,config,why);must(!source.isEmpty(),qUtf8Printable(why));
            resident::Vm vm(host);std::string error;must(vm.start(source.toStdString(),error),error.c_str());
            for(uint64_t now=0;now<1000&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);now+=20)vm.step(now);
            const bool shouldRun=i==1||i==3;must(host.logText.find("fixture_action")!=std::string::npos?shouldRun:!shouldRun,"Precheck did not guard task actions");
            must((vm.state()==resident::Vm::Completed)==(i<2),"Unverified module was treated as complete");
            QStringList messages;const auto receipt=TaskCompletion::takeReceipt("@TLBB_TASK_RESULT "+host.receipt+"\nordinary log",messages);
            must(TaskCompletion::verified(receipt)==(i<2),"Task receipt differs from module completion");
        }
        QStringList messages;must(TaskCompletion::takeReceipt("@TLBB_TASK_RESULT {broken}\n",messages).isEmpty(),"Malformed receipt accepted");
        must(TaskCompletion::takeReceipt("@TLBB_TASK_RESULT {\"verified\":true,\"status\":\"running\"}\n",messages).isEmpty(),"Nonterminal receipt accepted");
        for(const auto id:{"tlzz_shitu_xinlianxin","tlzz_xingyun","tlzz_gulanyu"}){
            QJsonObject config{{"legacy_id",id},{"engine","外部兼容"},{"timeout_seconds",300}};QString error;
            must(!validateLegacyConfig(config,error)&&error.contains("游戏内 Lua"),"Original bytecode silently fell back to reconstructed code");
        }
    });
    test("original_daily_sdk_text_counts_limits_and_queue_progression",[&]{
        QJsonArray cases;
        const auto dll=LoadLibraryExW(reinterpret_cast<LPCWSTR>(QString(root+"/../Bin64/LuaPlus.dll").utf16()),nullptr,LOAD_LIBRARY_SEARCH_DLL_LOAD_DIR|LOAD_LIBRARY_SEARCH_DEFAULT_DIRS);
        must(dll,"SDK unavailable for daily compatibility fixture");
        using namespace game_lua;
        auto create=api<void*(*)(bool,bool)>(dll,"?Create@LuaState@LuaPlus@@SAPEAV12@_N0@Z");auto native=api<void*(*)(void*)>(dll,"?GetCState@LuaState@LuaPlus@@QEAAPEAUlua_State@@XZ");
        auto destroy=api<void(*)(void*)>(dll,"?Destroy@LuaState@LuaPlus@@SAXPEAV12@@Z");auto ctor=api<void(*)(void*,void*,int)>(dll,"??0LuaObject@LuaPlus@@QEAA@PEAVLuaState@1@H@Z");auto dtor=api<void(*)(void*)>(dll,"??1LuaObject@LuaPlus@@QEAA@XZ");
        auto setTop=api<void(*)(void*,int)>(dll,"lua_settop");auto owner=create(false,false);auto vm=native(owner);
        struct Cleanup{HMODULE dll;void *owner,*registration;void(*destroy)(void*);void(*dtor)(void*);~Cleanup(){dtor(registration);destroy(owner);FreeLibrary(dll);}};
        for(const auto name:{"luaopen_base","luaopen_table","luaopen_string","luaopen_math"}){api<int(*)(void*)>(dll,name)(vm);setTop(vm,0);}
        api<void(*)(void*)>(dll,"lua_newtable")(vm);alignas(16) unsigned char registration[80]{};ctor(registration,owner,1);setTop(vm,0);Cleanup cleanup{dll,owner,registration,destroy,dtor};
        auto load=api<int(*)(void*,const char*,size_t,const char*)>(dll,"luaL_loadbuffer");auto call=api<int(*)(void*,int,int,int)>(dll,"lua_pcall");
        auto run=[&](QString kind,QString seed,QJsonObject extra,int expectedClaims,int expectedJoins,QString expectedResult,QString expectedError={}){
            const auto game=resident::convert(dailyFakeGame,CP_UTF8,936);must(load(vm,game.data(),game.size(),"=daily.fixture")==0&&call(vm,0,0,0)==0,"Fake game setup failed");setTop(vm,0);
            resident::GameTextSession text(dll,registration);text.evaluate(("W.kind='"+kind+"' "+seed).toStdString(),"",0);
            DailySdkHost host(dll,registration,text,kind);host.allowSpend=extra.value("allow_spend").toBool(true);
            const QString id=kind=="shitu"?"tlzz_shitu_xinlianxin":kind=="xingyun"?"tlzz_xingyun":"tlzz_gulanyu";
            QJsonObject config{{"legacy_id",id},{"engine","游戏内 Lua"},{"timeout_seconds",300},{"allow_spend",host.allowSpend},{"validation_contract","original_daily_v1"}};
            for(auto i=extra.begin();i!=extra.end();++i)config.insert(i.key(),i.value());
            const auto probe=temporary+"/original-daily-"+kind+".lua";QFile f(probe);must(f.open(QIODevice::WriteOnly),"Daily entry fixture unavailable");
            f.write("Bank_GetItem=function() return 0 end Bank_SaveItem=function() return 0 end Bag_Move2TempBank=function() end\n");
            QFile original(root+"/scripts/legacy/original/daily/"+kind+".lua");must(original.open(QIODevice::ReadOnly),"Direct original entry missing");f.write(original.readAll());f.close();
            QString error;const auto source=prepareResidentScript(root+"/scripts/legacy",probe,config,error);must(!source.isEmpty(),qUtf8Printable(error));
            resident::Vm task(host);std::string startError;must(task.start(source.toStdString(),startError),startError.c_str());
            for(uint64_t now=0;now<=180000&&(task.state()==resident::Vm::Running||task.state()==resident::Vm::Sleeping);now+=20)task.step(now);
            const auto counts=text.evaluate("return W.claims,W.joins","nn",2);
            must(counts[0].number==expectedClaims,qUtf8Printable(kind+" unexpected claim count: "+QString::number(counts[0].number)+"; "+host.logs+QString::fromStdString(task.error())));
            must(counts[1].number==expectedJoins,"Lottery join was not submitted exactly as expected");
            QStringList messages;const auto receipt=TaskCompletion::takeReceipt("@TLBB_TASK_RESULT "+host.result+"\n"+host.logs,messages);
            if(expectedError.isEmpty()){
                must(task.state()==resident::Vm::Completed,qUtf8Printable(QString::fromStdString(task.error())+host.logs));
                must(receipt.value("verified").toBool()&&receipt.value("status").toString()==expectedResult,qUtf8Printable("Unexpected task receipt: "+host.result));
                FlowRunner flow;QString flowError;QJsonObject params{{"failure","停止队列"}};
                QJsonObject first{{"node_id","first"},{"task",id},{"enabled",true},{"params",params}},second{{"node_id","next"},{"task","wait"},{"enabled",true},{"params",params}};
                must(flow.start({{"queue",QJsonArray{first,second}},{"scheduled",QJsonArray{}},{"flow",QJsonObject{}}},flowError),qUtf8Printable(flowError));
                const auto at=QDateTime::currentDateTime();must(flow.poll(at).value("node_id").toString()=="first","First queue node not started");flow.finish(true,receipt.value("status").toString());
                if(expectedResult=="limit_reached")must(flow.states().value("first").toString()=="已达上限","Daily cap was mislabeled as quantity completed");
                must(flow.poll(at.addSecs(1)).value("node_id").toString()=="next","Verified original task did not advance queue");
            }else{must(task.state()==resident::Vm::Failed&&QString::fromStdString(task.error()).contains(expectedError),qUtf8Printable("Unexpected failure: "+QString::fromStdString(task.error())+host.logs));must(receipt.isEmpty(),"Failed task generated a completion receipt");}
            cases.append(QJsonObject{{"task",id},{"seed",seed},{"parameters",extra},{"actual_claims",int(counts[0].number)},
                {"actual_joins",int(counts[1].number)},{"receipt",receipt},{"expected_error",expectedError},{"passed",true}});
        };
        run("shitu","W.done=true",{},0,0,"already_done");
        run("shitu","",{},1,0,"done");
        run("shitu","W.noDialog=true",{},0,0,"","未确认 NPC 对话");
        run("shitu","W.noeffect=true",{},1,0,"","不重复领取");
        run("xingyun","W.played=true",{{"allow_spend",true}},0,0,"done");
        run("xingyun","",{{"allow_spend",true}},0,1,"done");
        run("xingyun","",{{"allow_spend",false}},0,0,"","允许支付");
        run("xingyun","W.cooldown=true",{{"allow_spend",true}},0,0,"already_done");
        run("xingyun","W.noeffect=true",{{"allow_spend",true}},0,1,"","不重复参加");
        run("gulanyu","W.gem=3",{{"gulanyu_list","红宝石|1"},{"gulanyu_count_mode","持有目标总数"}},0,0,"already_done");
        run("gulanyu","W.gem=3",{{"gulanyu_list","红宝石|1"}},1,0,"done");
        run("gulanyu","W.gem=3",{{"gulanyu_list","红宝石|2"}},2,0,"done");
        run("gulanyu","",{{"gulanyu_list","红宝石|2 黄玉|1"}},3,0,"done");
        run("gulanyu","W.material=2",{{"gulanyu_list","红宝石|3"},{"gulanyu_count_mode","持有目标总数"}},1,0,"done");
        run("gulanyu","W.limit=true",{{"gulanyu_list","红宝石|2"}},0,0,"limit_reached");
        run("gulanyu","W.limitOnSubmit=true",{{"gulanyu_list","红宝石|2"}},1,0,"limit_reached");
        run("gulanyu","W.limitAfter=2",{{"gulanyu_list","红宝石|5"}},2,0,"limit_reached");
        run("gulanyu","W.noeffect=true",{{"gulanyu_list","红宝石|2"}},1,0,"","未确认物品增加");
        run("gulanyu","",{{"gulanyu_list","红宝石|0"}},0,0,"","格式无效");
        run("gulanyu","W.unreadableBag=true",{{"gulanyu_list","红宝石|1"}},0,0,"","base inventory unavailable");
        QDir().mkpath(root+"/artifacts/npc-lua-compat-0.15.0");
        QFile report(root+"/artifacts/npc-lua-compat-0.15.0/daily-task-cases.json");must(report.open(QIODevice::WriteOnly),"Daily task report unavailable");
        report.write(QJsonDocument(QJsonObject{{"status","pass"},{"case_count",cases.size()},{"cases",cases},{"real_game_tested",false}}).toJson());
    });
}
}
