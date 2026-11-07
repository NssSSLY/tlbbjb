#pragma once
#include "resident_tests.hpp"
namespace tlbb {
struct OriginalRuleFake:ResidentFake {
    bool empty=false,reused=false,badDeath=false,entryFails=false,emptyAfterCast=false;int members=3,deathReads=0,moves=0;QStringList options,trace;
    OriginalRuleFake(){scene=61;entryScene=61;}
    resident::Values call(const std::string &op,const std::string &value)override{
        if(trace.size()<50)trace<<QString("host %1 scene %2").arg(QString::fromStdString(op)).arg(scene);
        return ResidentFake::call(op,value);
    }
    resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a)override{
        using resident::Value;
        if(trace.size()<50)trace<<QString("snippet %1 scene %2 args %3 %4 %5").arg(id).arg(scene).arg(a.ints[0]).arg(a.reals[0]).arg(a.reals[1]);
        if(id==gameplay::Dismount)return {Value(0)};
        if(id==gameplay::CloseAll)return {Value(1)};
        if(id==gameplay::TeamCount)return {Value(members)};
        if(id==gameplay::DebugMessages)return {Value(0),Value(std::string())};
        if(id==gameplay::NpcEventItem)return {Value(1),Value(std::string())};
        if(id==gameplay::CombatName&&emptyAfterCast)return {Value(1),Value(0),Value(std::string("棋子"))};
        if(id==gameplay::QuestOption){const auto name=QString::fromWCharArray(a.text);options<<name;
            if(!entryFails&&(name=="#{QJYH_150315_02}"||name=="#{QJYH_150315_03}"||name=="珍珑棋局"))scene=61;
            if(name=="确定")scene=1;
            return {Value(1),Value(name.toStdString())};}
        if(id==gameplay::RunTo)++moves;
        if(id==gameplay::CombatScan){
            if(empty||(casts>=3&&a.ints[1]<0))return {Value(1),Value(-1),Value(-1),Value(0),Value(0),Value(0),Value(0),Value(100)};
            if(casts>=3&&a.ints[1]>=0){++deathReads;if(badDeath||reused)return {Value(3),Value(-1),Value(-1),Value(0),Value(0),Value(0),Value(0),Value(100)};}
        }
        return ResidentFake::snippet(id,a);
    }
    std::vector<resident::Object> objects()override{
        if(empty||(emptyAfterCast&&casts>=3))return {{20,120,40,40,100,false,"齐圣",30}};
        const bool dead=casts>=3;
        return {{10,dead&&reused?202:101,65,64,dead?0.0:100.0,!dead,emptyAfterCast?"棋子":"远古棋魂",1},{20,120,40,40,100,false,"齐圣",30}};
    }
};
template<class Test>void originalRulesTests(const QString &root,const QString &temporary,Test test){
    auto must=[](bool value,const char *why){if(!value)throw std::runtime_error(why);};
    auto execute=[&](OriginalRuleFake &host,QJsonObject config,uint64_t limit,std::string &error){
        QString preparation;auto source=prepareResidentScript(root+"/scripts/legacy",root+"/scripts/legacy/original/qiju.lua",config,preparation);
        must(preparation.isEmpty(),qPrintable(preparation));resident::Vm vm(host);must(vm.start(source.toStdString(),error),error.c_str());
        for(uint64_t now=0;now<=limit&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);now+=20)vm.step(now);
        error=vm.error();return vm.state();
    };
    test("original_qiju_bytecode_manual_auto_entry_and_config_binding",[&]{
        for(int mode=0;mode<3;++mode){auto config=combatTestConfig("zhenlong_combat");config.insert("rule_source","原规则");config.insert("entry_mode",mode?"自动入场":"已在副本");config.insert("original_quick_mode",mode==2);
            OriginalRuleFake host;if(mode)host.scene=1;std::string error;const auto state=execute(host,config,60000,error);
            must(state==resident::Vm::Completed,("mode="+std::to_string(mode)+" scene="+std::to_string(host.scene)+" casts="+std::to_string(host.casts)+" options="+host.options.join("|").toStdString()+" "+error+" | "+host.logText+host.trace.join(" | ").toStdString()).c_str());must(host.casts==3&&host.kills==1&&host.boss==1&&host.scene==1&&host.deathReads>=2,"Original bytecode did not confirm a complete dungeon lifecycle");
            if(mode){must(host.options.contains(mode==2?"#{QJYH_150315_03}":"#{QJYH_150315_02}"),"Original quick-mode parameter did not change the original dialog branch");}
        }
    });
    test("original_qiju_empty_health_identity_and_uncertain_guards",[&]{
        auto config=combatTestConfig("zhenlong_combat");config.insert("entry_mode","已在副本");
        for(int mode=0;mode<6;++mode){OriginalRuleFake host;host.empty=mode==0;host.low=mode==1;host.reused=mode==2;host.badDeath=mode==3;host.uncertain=mode==4;host.emptyAfterCast=mode==5;
            std::string error;const auto state=execute(host,config,160000,error);
            if(mode==0)must(state==resident::Vm::Running||state==resident::Vm::Sleeping,"Original initial spawn wait was changed");
            else must(state==resident::Vm::Failed,("Original rule failure ignored: "+std::to_string(mode)+" "+error+host.logText).c_str());
            must(host.boss==0,"Unverified boss reported as completed");
            if(mode==1)must(host.casts==0&&host.moves==0,"Low health moved or attacked");
            if(mode==4)must(host.casts==1,"Uncertain original cast replayed");
        }
    });
    test("original_qiju_entry_is_once_and_external_fallback_is_explicit",[&]{
        auto config=combatTestConfig("zhenlong_combat");config.insert("entry_mode","自动入场");
        OriginalRuleFake noEntry;noEntry.scene=1;noEntry.entryFails=true;std::string error;must(execute(noEntry,config,60000,error)==resident::Vm::Failed,"Unconfirmed entry was accepted");
        must(noEntry.options.count("珍珑棋局")<=1&&noEntry.options.count("#{QJYH_150315_02}")<=1,"Original entry request replayed");
        OriginalRuleFake small;small.scene=1;small.members=2;must(execute(small,config,60000,error)==resident::Vm::Failed&&small.options.isEmpty(),"Default original three-member requirement was ignored");
        config.insert("original_team_count",3);OriginalRuleFake three;three.scene=1;three.members=3;must(execute(three,config,60000,error)==resident::Vm::Completed,("Explicit team count not applied: "+error).c_str());
        config.insert("engine","外部兼容");config.insert("rule_source","原规则");QString validation;must(!validateLegacyConfig(config,validation),"Original bytecode accepted on unavailable external backend");
        config.insert("rule_source","兼容重建");must(validateLegacyConfig(config,validation),qPrintable(validation));
        OriginalRuleFake fallback;config.insert("entry_mode","已在副本");must(execute(fallback,config,60000,error)==resident::Vm::Completed,error.c_str());
    });
    test("original_object_filters_keep_positional_arguments_and_utf8",[&]{
        const auto entry=temporary+"/original-filters.lua";QFile out(entry);must(out.open(QIODevice::WriteOnly),"Filter fixture missing");
        out.write("LoadScript('original_combat');BeginOriginalDungeon('qiju',61);local objects=Enum2XByClass('怪物',{0,-1},1);assert(#objects==1 and objects[1].id==10);local named=Enum2XByName('远古棋魂',{0,1,0,0},nil,nil,0);assert(#named==1 and named[1].name=='远古棋魂');assert(ReadConfigBool('ZH','xzk190')==true);local ok=pcall(ReadConfigBool,'unknown','bad');assert(not ok)");out.close();
        auto config=combatTestConfig("zhenlong_combat");config.insert("original_quick_mode",true);QString preparation;const auto source=prepareResidentScript(root+"/scripts/legacy",entry,config,preparation);must(preparation.isEmpty(),qPrintable(preparation));
        OriginalRuleFake host;resident::Vm vm(host);std::string error;must(vm.start(source.toStdString(),error),error.c_str());for(uint64_t n=0;n<20000&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);n+=20)vm.step(n);must(vm.state()==resident::Vm::Completed,vm.error().c_str());
    });
    test("original_dungeon_battle_preserves_explicit_target_and_current_position",[&]{
        struct TargetFixture:OriginalRuleFake {
            QList<int> targetIds,serverIds;QList<double> xs,ys;
            std::vector<resident::Object> objects()override{return {{10,101,65,64,100,true,"怪甲"},{11,102,66,64,100,true,"怪乙"},{20,120,40,40,100,false,"齐圣"}};}
            resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a)override{
                if(id==gameplay::CombatScan){targetIds<<a.ints[1];serverIds<<a.ints[2];xs<<a.reals[0];ys<<a.reals[1];return {resident::Value(1),resident::Value(a.ints[1]),resident::Value(a.ints[2]),resident::Value(1),resident::Value(66),resident::Value(64),resident::Value(1),resident::Value(100)};}
                return OriginalRuleFake::snippet(id,a);
            }
        };
        const auto path=temporary+"/original-target.lua";QFile out(path);must(out.open(QIODevice::WriteOnly),"Original target fixture missing");
        out.write("LoadScript('original_combat');BeginOriginalDungeon('qiju',61);FubenAttack(10);Sleep(1600);FubenAttack(11);Sleep(1600);FubenAttack(999)");out.close();
        auto config=combatTestConfig("zhenlong_combat");config.insert("entry_mode","已在副本");QString preparation;
        const auto source=prepareResidentScript(root+"/scripts/legacy",path,config,preparation);must(preparation.isEmpty(),qPrintable(preparation));
        TargetFixture host;host.x=80;host.y=81;resident::Vm vm(host);std::string error;must(vm.start(source.toStdString(),error),error.c_str());
        for(uint64_t now=0;now<20000&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);now+=20)vm.step(now);
        must(vm.state()==resident::Vm::Failed&&QString::fromStdString(vm.error()).contains("指定的敌方目标不可确认"),"Unknown selected target did not stop the original rule");
        must(host.targetIds==QList<int>{10,11}&&host.serverIds==QList<int>{101,102}&&host.casts==2,"Original target switch was ignored or selected a different enemy");
        must(host.xs==QList<double>{80,80}&&host.ys==QList<double>{81,81},"Original combat used fixed dungeon coordinates");
        must(host.kills==0&&host.boss==0,"Target switch reported an unconfirmed kill");
    });
    test("original_sijue_and_yanzi_bytecode_start_and_dependency_probe",[&]{
        const auto directory=root+"/scripts/legacy";
        auto quoted=[](const QString &v){const QByteArray a=QJsonDocument(QJsonArray{v}).toJson(QJsonDocument::Compact);return a.mid(1,a.size()-2);};
        for(const QString token:{"002e1226","00313c18"}){
            QString error;QJsonObject chunks,names;must(originalRuleClosure(directory,token,chunks,names,error),qPrintable(error));
            const auto path=temporary+"/original-dungeon-probe.lua";QFile out(path);must(out.open(QIODevice::WriteOnly),"Original dungeon probe missing");
            QByteArray script="__original_rules={";
            for(auto it=chunks.begin();it!=chunks.end();++it)script+="["+quoted(it.key())+"]="+quoted(it.value().toString())+",";
            script+="}\n__original_names={";
            for(auto it=names.begin();it!=names.end();++it)script+="["+quoted(it.key())+"]="+quoted(it.value().toString())+",";
            script+="}\nScriptOnStart=function(n) started=n end\nScriptOnStop=function() error('unexpected early stop') end\n"
                    "GetConfigBool=function() return false end\nReadConfigBool=GetConfigBool\n"
                    "ReadConfigText=function() return '普通' end\nGetConfigText=function() return '3' end\n"
                    "HandleTextToNumber=function() return 3 end\ng_pick={} CDG={hp={}}\nRecvState=function(n) recv=n end\n"
                    "GetSceneID=function() error('__before_game_scene__') end\n"
                    "local ok,err=pcall(RunOriginalRule,"+quoted(token)+")\n"
                    "assert(not ok and tostring(err):find('__before_game_scene__',1,true),tostring(err))\n";
            script+=token=="002e1226"?"assert(started=='四绝庄' and type(SJZ_Start)=='function')":"assert(started=='讨伐燕子坞' and recv==3 and type(YZW_CallBack)=='function')";
            out.write(script);out.close();
            const auto prepared=prepareResidentScript(directory,path,{},error);must(error.isEmpty(),qPrintable(error));
            ResidentFake host;resident::Vm vm(host);std::string why;must(vm.start(prepared.toStdString(),why),why.c_str());
            for(uint64_t now=0;now<30000&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);now+=20)vm.step(now);
            must(vm.state()==resident::Vm::Completed,(token.toStdString()+": "+vm.error()).c_str());
            must(host.casts==0&&host.evaluations==0&&vm.allocated()==0,"Original dungeon probe accessed game or retained its VM");
        }
    });
}
}
