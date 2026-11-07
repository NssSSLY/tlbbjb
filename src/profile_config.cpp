#include "profile_config.hpp"
#include "flow_runner.hpp"
#include <QJsonArray>
#include <QJsonDocument>
#include <QUuid>

namespace tlbb {
QJsonObject copyTaskConfiguration(const QJsonObject &source,const QJsonObject &target){
    auto result=target;
    for(const auto &key:{"tasks","queue","scheduled","flow","favorites","bag","supply","protection","team","trade","other"})result.insert(key,source.value(key));
    const auto targetTasks=target.value("tasks").toObject();
    auto skills=[&](const QString &id,bool resolve){auto v=targetTasks.value(id).toObject().value("combat_skills").toString();
        if(resolve&&v.trimmed().isEmpty())v=target.value("battle").toObject().value("skills").toString();
        return v;};
    auto tasks=result.value("tasks").toObject();
    for(auto it=tasks.begin();it!=tasks.end();++it){auto p=it.value().toObject();if(p.contains("combat_skills")){p.insert("combat_skills",skills(it.key(),false));p.insert("battle_system",target.value("battle"));it.value()=p;}}
    result.insert("tasks",tasks);
    for(const auto &key:{"queue","scheduled"}){auto nodes=result.value(key).toArray();
        for(int i=0;i<nodes.size();++i){auto n=nodes[i].toObject();auto p=n.value("params").toObject();
            if(p.contains("combat_skills")){p.insert("combat_skills",skills(n.value("task").toString(),true));p.insert("battle_system",target.value("battle"));n.insert("params",p);nodes[i]=n;}}
        result.insert(key,nodes);
    }
    auto bag=result.value("bag").toObject();bag.insert("destroy_enabled",false);bag.insert("preview_valid",false);result.insert("bag",bag);
    return result;
}
QJsonObject migrateTaskProfile(QJsonObject profile) {
    if(!profile.value("tasks").isObject())profile.insert("tasks",QJsonObject{});
    for(const auto &key:{"queue","scheduled"}) {
        auto list=profile.value(key).toArray();
        for(int i=0;i<list.size();++i){auto n=list[i].toObject();if(n.value("node_id").toString().isEmpty())n.insert("node_id",QUuid::createUuid().toString(QUuid::WithoutBraces));if(!n.contains("enabled"))n.insert("enabled",true);list[i]=n;}
        profile.insert(key,list);
    }
    if(profile.value("panel_schema").toInt()<5){profile.insert("tab",0);profile.insert("parameter_task","plant");}
    profile.insert("panel_schema",5);
    auto flow=profile.value("flow").toObject();
    const QJsonObject defaults{{"loop",false},{"loop_limit",1},{"monitor_scheduled",true},{"daily_scheduled",true},{"delete_completed",false}};
    for(auto i=defaults.begin();i!=defaults.end();++i)if(!flow.contains(i.key()))flow.insert(i.key(),i.value());
    profile.insert("flow",flow);
    auto bag=profile.value("bag").toObject();bag.insert("destroy_enabled",false);bag.insert("preview_valid",false);profile.insert("bag",bag);
    return profile;
}
QJsonObject portableProfile(const QJsonObject &profile) {
    QJsonObject result;
    for(const auto &key:{"tasks","queue","scheduled","flow","favorites","battle","bag","supply","protection","team","trade","other","parameter_task","panel_schema"})
        if(profile.contains(key))result.insert(key,profile.value(key));
    result=migrateTaskProfile(result);
    return {{"kind","tlbb_task_profile"},{"schema",1},{"config",result}};
}
bool readPortableProfile(const QJsonObject &document,QJsonObject &configuration,QString &error) {
    configuration={};error.clear();
    if(document.value("kind").toString()!="tlbb_task_profile"||document.value("schema")!=QJsonValue(1)
        ||!document.value("config").isObject()||QJsonDocument(document).toJson(QJsonDocument::Compact).size()>1024*1024){error="不是有效的任务配置文件，或超过 1 MiB";return false;}
    const auto original=document.value("config").toObject();
    if(!original.value("tasks").isObject()||original.value("tasks").toObject().size()>512){error="任务参数格式无效或超过 512 项";return false;}
    for(const auto &key:{"queue","scheduled"})if(!original.value(key).isArray()||original.value(key).toArray().size()>64){error="任务列表格式无效或超过 64 项";return false;}
    for(const auto &key:{"battle","bag","supply","protection","team","trade","other","flow"})if(original.contains(key)&&!original.value(key).isObject()){error="规则配置格式无效";return false;}
    const auto listings=original.value("trade").toObject().value("listings");
    if(!listings.isUndefined()&&(!listings.isArray()||listings.toArray().size()>128)){error="上架规则格式无效或超过 128 条";return false;}
    if(original.value("favorites").toArray().size()>128){error="常用任务超过 128 项";return false;}
    configuration=portableProfile(original).value("config").toObject();
    if(!FlowRunner::validate({{"queue",configuration.value("queue")},{"scheduled",configuration.value("scheduled")},{"flow",configuration.value("flow")}},error,true)){configuration={};return false;}
    return true;
}
} // namespace tlbb
