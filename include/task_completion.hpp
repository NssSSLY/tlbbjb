#pragma once
#include <QJsonDocument>
#include <QJsonObject>
#include <QStringList>
namespace tlbb::TaskCompletion {
inline bool verified(const QJsonObject &receipt) {
    const auto status=receipt.value("status").toString();
    return receipt.value("verified").toBool()&&
        (status=="done"||status=="already_done"||status=="limit_reached");
}
inline bool eventVerified(const QJsonObject &event) {
    return event.value("preview").toBool()||event.value("verified").toBool()||verified(event.value("task_result").toObject());
}
// How a finished Lua task is judged. A task with a completion contract stands on its receipt alone
// (healer-only, a teammate's kills or "today's count is full" are valid ends); only the pure kill task
// counts its own kills; the chess flow needs the boss and the exit; any other combat task ends
// unverified and the queue applies its failure policy.
struct Judgement{bool accepted=false;bool verified=false;QString reason;};
struct FinishFacts{
    QString contract;QJsonObject receipt;bool combat=false;bool killTask=false;bool chess=false;
    int kills=0;int killGoal=1;bool boss=false;bool leftScene=false;
};
inline Judgement judge(const FinishFacts &f){
    if(!f.contract.isEmpty())return verified(f.receipt)?Judgement{true,true,{}}:Judgement{false,false,"Lua 已退出，但任务完成条件未核验，未进入下一项"};
    if(f.chess)return f.boss&&f.leftScene?Judgement{true,true,{}}:Judgement{false,false,"棋局首领死亡或离场未确认，未报告通关"};
    if(f.killTask)return f.kills>=f.killGoal?Judgement{true,true,{}}:Judgement{false,false,QString("确认击杀 %1/%2，刷怪目标未完成").arg(f.kills).arg(f.killGoal)};
    return {true,verified(f.receipt),{}};
}
// Shared by Worker (finish facts from its config and resident poll state, the completed event) and the
// launcher (event → queue outcome), so tests exercise the same path instead of rebuilding it by hand.
inline FinishFacts facts(const QJsonObject &config,bool combat,bool killTask,const QJsonObject &state,bool leftScene){
    FinishFacts f;f.contract=config.value("validation_contract").toString();f.receipt=state.value("task_result").toObject();
    f.combat=combat;f.killTask=killTask;f.chess=config.value("legacy_id").toString()=="zhenlong_combat";
    f.kills=state.value("kills").toInt();f.killGoal=config.value("combat_kill_goal").toInt(1);f.boss=state.value("boss").toBool();f.leftScene=leftScene;
    return f;
}
inline QJsonObject completedEvent(const Judgement &j,const QJsonObject &receipt){
    return {{"event","completed"},{"task_result",receipt},{"verified",j.verified}};
}
struct FlowOutcome{bool verified=false;QString outcome;};
inline FlowOutcome flowOutcome(const QJsonObject &event){
    const bool ok=eventVerified(event);
    return {ok,ok?event.value("task_result").toObject().value("status").toString():QString("unverified")};
}
inline QJsonObject takeReceipt(const QString &wire,QStringList &messages) {
    QJsonObject result;
    const QString prefix="@TLBB_TASK_RESULT ";
    for(const auto &line:wire.split('\n',Qt::SkipEmptyParts)) {
        if(!line.startsWith(prefix)){messages.append(line);continue;}
        const auto json=line.mid(prefix.size()).toUtf8();
        if(json.size()>1024)return {};
        const auto value=QJsonDocument::fromJson(json).object();
        if(!verified(value)||!result.isEmpty())return {};
        result=value;
    }
    return result;
}
}
