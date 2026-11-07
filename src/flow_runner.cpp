#include "flow_runner.hpp"
#include <QJsonDocument>
#include <QRegularExpression>
#include <QSet>
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QSaveFile>
#include <cmath>

namespace tlbb {
static bool integer(const QJsonValue &v,int low,int high) {
    return v.isDouble()&&std::isfinite(v.toDouble())&&std::floor(v.toDouble())==v.toDouble()
        &&v.toDouble()>=low&&v.toDouble()<=high;
}
bool FlowRunner::validate(const QJsonObject &plan,QString &error,bool allowEmpty) {
    error.clear();
    auto fail=[&](const QString &s){error=s;return false;};
    if(QJsonDocument(plan).toJson(QJsonDocument::Compact).size()>256*1024)return fail("流程配置超过 256 KiB");
    QSet<QString> ids;int enabled=0;
    for(const auto &key:{"queue","scheduled"}) {
        const auto v=plan.value(key);if(!v.isArray()||v.toArray().size()>64)return fail("顺序和定时列表分别最多 64 项");
        for(const auto &entry:v.toArray()) {
            if(!entry.isObject())return fail("任务节点格式无效");
            const auto n=entry.toObject();const auto id=n.value("node_id").toString();
            if(id.isEmpty()||id.size()>80||ids.contains(id)||!QRegularExpression("^[A-Za-z0-9_-]+$").match(id).hasMatch()
                ||n.value("task").toString().isEmpty()||!n.value("params").isObject()
                ||!n.value("enabled").isBool())return fail("任务身份、开关或参数无效");
            ids.insert(id);if(n.value("enabled").toBool()&&(QString(key)=="queue"||plan.value("flow").toObject().value("monitor_scheduled").toBool(true)))++enabled;
            if(QString(key)=="scheduled"&&(!integer(n.value("start_minute"),0,1439)
                ||!integer(n.value("end_minute"),0,1439)||n.value("start_minute")==n.value("end_minute")))
                return fail("定时时间必须有效，开始和结束不能相同");
        }
    }
    const auto options=plan.value("flow").toObject();
    if(options.contains("loop_limit")&&!integer(options.value("loop_limit"),0,999))return fail("循环上限应为 0–999");
    if(enabled==0&&!allowEmpty)return fail("没有启用的任务");
    return true;
}
bool FlowRunner::start(const QJsonObject &plan,QString &error) {
    if(active_){error="当前流程仍在运行，请先停止";return false;}
    if(!validate(plan,error))return false;
    queue_=plan.value("queue").toArray();scheduled_=plan.value("scheduled").toArray();options_=plan.value("flow").toObject();
    journalError_.clear();
    if(!journalPath_.isEmpty()&&QFile::exists(journalPath_)){
        QFile file(journalPath_);
        if(!file.open(QIODevice::ReadOnly)||file.size()>256*1024){error="定时执行记录不可读，流程未开始";return false;}
        const auto doc=QJsonDocument::fromJson(file.readAll()).object();
        if(doc.value("schema")!=1||!doc.value("records").isObject()||doc.value("records").toObject().size()>64){error="定时执行记录损坏，原文件已保留";return false;}
        journal_=doc.value("records").toObject();
    }
    QJsonObject retained;claimed_.clear();
    for(const auto &v:scheduled_){const auto n=v.toObject();const auto id=n.value("node_id").toString();const auto r=journal_.value(id).toObject();
        if(r.isEmpty())continue;
        if(r.value("task")!=n.value("task")||r.value("start_minute")!=n.value("start_minute")||r.value("end_minute")!=n.value("end_minute"))continue;
        const auto date=QDate::fromString(r.value("anchor").toString(),Qt::ISODate);
        if(!date.isValid()){error="定时执行日期损坏，流程未开始";return false;}
        retained.insert(id,r);claimed_.insert(id,date);
    }
    journal_=retained;
    current_={};states_={};next_=0;round_=1;active_=true;paused_=false;
    for(const auto &list:{queue_,scheduled_})for(const auto &v:list){const auto n=v.toObject();states_.insert(n.value("node_id").toString(),n.value("enabled").toBool()?"等待":"禁用");}
    return true;
}
bool FlowRunner::persistJournal(){
    if(journalPath_.isEmpty())return true;
    QDir().mkpath(QFileInfo(journalPath_).absolutePath());QSaveFile file(journalPath_);
    const auto bytes=QJsonDocument(QJsonObject{{"schema",1},{"records",journal_}}).toJson();
    if(file.open(QIODevice::WriteOnly)&&file.write(bytes)==bytes.size()&&file.commit())return true;
    journalError_="定时执行记录保存失败，流程已停止";active_=false;return false;
}
QJsonObject FlowRunner::poll(const QDateTime &now) {
    if(!active_||paused_||busy()||!now.isValid())return {};
    const bool daily=options_.value("daily_scheduled").toBool(true);
    bool future=false;
    for(const auto &v:scheduled_) {
        if(!options_.value("monitor_scheduled").toBool(true))break;
        auto n=v.toObject();if(!n.value("enabled").toBool())continue;
        const QString id=n.value("node_id").toString();
        if(!daily&&claimed_.contains(id)){states_.insert(id,"本项已有执行记录");continue;}
        future=true;
        const int start=n.value("start_minute").toInt(),end=n.value("end_minute").toInt();
        const int minute=now.time().hour()*60+now.time().minute();
        const bool overnight=start>end;
        if(!(overnight?(minute>=start||minute<end):(minute>=start&&minute<end)))continue;
        const QDate anchor=overnight&&minute<end?now.date().addDays(-1):now.date();
        // At most one claim per window, including clock rollback. Storage is bounded by node count.
        if(claimed_.contains(id)&&claimed_.value(id)>=anchor){
            const auto status=journal_.value(id).toObject().value("status").toString();
            states_.insert(id,status=="done"||status=="already_done"?"本时段已完成":status=="limit_reached"?"本时段已达上限":status=="failed"?"本时段执行失败":"已有执行记录，待核验");
            continue;
        }
        const auto before=journal_;
        journal_.insert(id,QJsonObject{{"task",n.value("task")},{"start_minute",start},{"end_minute",end},{"anchor",anchor.toString(Qt::ISODate)},{"status","issued"}});
        if(!persistJournal()){journal_=before;return {};}
        claimed_.insert(id,anchor);n.insert("scheduled",true);current_=n;states_.insert(id,"运行");return n;
    }
    while(next_<queue_.size()) {
        auto n=queue_[next_++].toObject();if(!n.value("enabled").toBool())continue;
        n.insert("scheduled",false);current_=n;states_.insert(n.value("node_id").toString(),"运行");return n;
    }
    const int limit=options_.value("loop_limit").toInt(1);
    bool hasRegular=false;for(const auto &n:queue_)hasRegular|=n.toObject().value("enabled").toBool();
    if(hasRegular&&options_.value("loop").toBool()&&(limit==0||round_<limit)) {
        ++round_;next_=0;
        // Return to the caller; the shared timer advances the next round without a busy loop.
        return {};
    }
    if(!future||!options_.value("monitor_scheduled").toBool(true))active_=false;
    return {};
}
QJsonObject FlowRunner::finish(bool success,const QString &outcome) {
    const auto node=current_;if(node.isEmpty())return {};
    const QString label=!success?(outcome=="unverified"?"未核验":"失败"):outcome=="limit_reached"?"已达上限":outcome=="already_done"?"此前已完成":"完成";
    states_.insert(node.value("node_id").toString(),label);current_={};
    if(node.value("scheduled").toBool()){
        const auto id=node.value("node_id").toString();auto record=journal_.value(id).toObject();
        record.insert("status",success?(outcome.isEmpty()?"done":outcome):outcome=="unverified"?"unverified":"failed");journal_.insert(id,record);persistJournal();
    }
    if(success&&outcome!="limit_reached"&&node.value("scheduled").toBool()&&deleteCompleted()){
        for(int i=0;i<scheduled_.size();++i){auto entry=scheduled_[i].toObject();if(entry.value("node_id")==node.value("node_id")){entry.insert("enabled",false);scheduled_[i]=entry;}}
    }
    if(!success) {
        const auto policy=node.value("params").toObject().value("failure").toString("停止队列");
        if(policy=="等待人工")paused_=true;
        else if(policy!="跳过本项")active_=false;
    }
    return node;
}
void FlowRunner::stop(){active_=false;paused_=false;current_={};}
QString FlowRunner::status()const {
    if(paused_)return "流程已暂停";
    if(!active_)return "流程已结束";
    if(busy())return current_.value("scheduled").toBool()?"定时任务运行":"顺序任务运行";
    return "等待定时时段 / 下一轮";
}
} // namespace tlbb
