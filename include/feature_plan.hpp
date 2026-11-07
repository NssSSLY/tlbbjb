#pragma once
#include <QJsonArray>
#include <QJsonObject>
#include <QStringList>
namespace tlbb {
inline QJsonObject plannedTask(const QJsonArray &catalog,const QString &id){
    for(const auto &v:catalog)if(v.toObject().value("id").toString()==id)return v.toObject();
    return {};
}
inline QString taskAdapterLabel(const QJsonObject &t){
    if(t.value("planning_only").toBool())return t.value("plan_priority").toString().startsWith("P0")?"优先待接入":"规划待接入";
    const auto id=t.value("id").toString();
    if(id=="daily_sign"||t.value("family").toString()=="legacy")return "已接入·待实测";
    return id=="luoyang_move"||id=="wait"?"已适配":"待适配";
}
inline QString plannedTaskReason(const QJsonObject &t){
    QStringList parts;for(const auto &v:t.value("planning_blockers").toArray())parts.append(v.toString());
    return parts.join("；");
}
}
