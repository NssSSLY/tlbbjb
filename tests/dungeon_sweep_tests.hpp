#pragma once
#include "resident_tests.hpp"
#include "task_completion.hpp"
#include <QFile>
namespace tlbb {
struct SweepFake:ResidentFake {
    QString target="讨伐燕子坞",receipt;int left=2,total=2,points=5,id=40,openCount=0,bossCount=0,okCount=0;
    bool page=false,bossDone=false,pending=false,missing=false,blockedPage=false,holdBoss=false,noCount=false,
         changeId=false,busyInitially=false,busyAfter=false,drainPoints=false,invalidTotal=false,loading=false;
    resident::Values snippet(uint32_t command,const gameplay::SnippetArgs &args)override{
        using resident::Value;const auto text=QString::fromWCharArray(args.text);
        if(command==gameplay::WindowVisible)return {Value(text=="SweepAll"?1:text=="SweepPage"&&page?1:0)};
        if(command==gameplay::SweepData)return {Value(busyInitially||(busyAfter&&bossCount>0)?1:0),Value(id),Value(0)};
        if(command==gameplay::SweepCount)return {Value(1)};
        if(command==gameplay::SweepEnum)return {Value(points),Value(8),Value(1),Value(2),Value(300),Value(left),Value(id),Value(0),Value((missing?QString("其他副本"):target).toStdString())};
        if(command==gameplay::SweepOpenPage){++openCount;if(!blockedPage)page=true;bossDone=false;return {Value(1)};}
        if(command==gameplay::SweepBoss){if(bossDone)return {Value(-1)};++bossCount;pending=true;bossDone=!holdBoss;return {Value(1)};}
        if(command==gameplay::UiCall){
            const auto function=QString::fromLatin1(gameplay::uiCalls[args.ints[0]].function);
            if(function=="SweepPage_OnOkClicked"){++okCount;if(pending){if(!noCount)--left;if(changeId)++id;if(drainPoints)points=0;pending=false;}}
            return {Value(1)};
        }
        if(command==gameplay::CloseNamed){if(QString::fromLatin1(gameplay::closableWindows[args.ints[0]])=="SweepPage")page=false;return {Value(1)};}
        return ResidentFake::snippet(command,args);
    }
    resident::Values evaluate(const std::string &code,const std::string &format,int count)override{
        if(code.find("campaign total unavailable")!=std::string::npos)return {resident::Value(invalidTotal?-1:total)};
        if(code.find("sweep page unavailable")!=std::string::npos)return {resident::Value(loading?0:bossDone?-1:1)};
        return ResidentFake::evaluate(code,format,count);
    }
    resident::Values call(const std::string &op,const std::string &value)override{
        if(op=="task_result"){receipt=QString::fromStdString(value);return {};}
        return ResidentFake::call(op,value);
    }
};
template<class Test>void dungeonSweepTests(const QString &root,Test test){
    auto must=[](bool value,const char *why){if(!value)throw std::runtime_error(why);};
    test("original_sweep_two_dungeons_precheck_receipt_and_no_replay",[&]{
        for(const QString id:{"tlzz_sweep_yanzi","tlzz_sweep_sijue"})for(int scenario=0;scenario<14;++scenario){
            SweepFake host;if(id=="tlzz_sweep_sijue")host.target="苏州四绝庄";
            if(scenario==1)host.left=0;
            if(scenario==2){host.left=0;host.total=0;}
            if(scenario==3)host.points=0;
            host.missing=scenario==4;host.blockedPage=scenario==5;host.holdBoss=scenario==6;
            host.noCount=scenario==7;host.changeId=scenario==8;host.busyInitially=scenario==9;host.drainPoints=scenario==10;
            host.invalidTotal=scenario==11;host.loading=scenario==12;host.busyAfter=scenario==13;
            QJsonObject cfg{{"legacy_id",id},{"engine","游戏内 Lua"},{"timeout_seconds",1300}};QString error,path;QJsonObject declaration;
            must(resolveLegacyEntry("scripts/builtin/legacy",id,declaration,path,error),qUtf8Printable(error));
            must(declaration.value("validation_contract").toString()=="original_sweep_v1", "Original sweep lacks its strict contract");
            const auto source=prepareResidentScript(root+"/scripts/legacy",path,cfg,error);must(error.isEmpty()&&!source.isEmpty(),qUtf8Printable(error));
            resident::Vm vm(host);std::string why;must(vm.start(source.toStdString(),why),why.c_str());
            for(uint64_t now=0;now<100000&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);now+=20)vm.step(now);
            QStringList messages;const auto receipt=TaskCompletion::takeReceipt("@TLBB_TASK_RESULT "+host.receipt+"\n",messages);
            if(scenario==0){must(vm.state()==resident::Vm::Completed,vm.error().c_str());must(host.left==0&&host.openCount==2&&host.bossCount==2&&receipt.value("status").toString()=="done","Two sweep rounds were not confirmed");}
            else if(scenario==1){must(vm.state()==resident::Vm::Completed&&host.openCount==0&&receipt.value("status").toString()=="already_done","Completed count was not checked before actions");}
            else if(scenario==2||scenario==3){must(vm.state()==resident::Vm::Completed&&host.openCount==0&&receipt.value("status").toString()=="limit_reached","No eligibility or insufficient points was reported as success");}
            else if(scenario==10){must(vm.state()==resident::Vm::Completed&&host.left==1&&host.openCount==1&&receipt.value("status").toString()=="limit_reached","Partial sweep and exhausted points were not distinguished");}
            else {must(vm.state()==resident::Vm::Failed&&receipt.isEmpty(),("Sweep missing/uncertain state reported completion "+std::to_string(scenario)+": "+vm.error()).c_str());
                must(host.openCount<=(scenario==4||scenario==9||scenario==11?0:1)&&host.bossCount<=1,"Sweep retried an unconfirmed action");}
            must(vm.allocated()==0,"Sweep task leaked its bounded VM");
        }
    });
}
}
