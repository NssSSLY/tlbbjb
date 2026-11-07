#pragma once
#include <QJsonObject>
namespace tlbb {
// Fixed task entries with specific permission from the user, not generic Lua.
inline void applyTaskPermissions(const QJsonObject &entry, QJsonObject &config) {
    if(entry.value("id").toString()=="orig_00267ca1" && entry.value("original_token").toString()=="00267ca1" && entry.value("entry").toString()=="original/generic_task.lua") config.insert("allow_spend",true);
    if(entry.value("id").toString()=="tlzz_wish_1001" && entry.value("entry").toString()=="rebuilt/wish_1001.lua")
        config.insert("allow_item",true);
    if(entry.value("id").toString()=="tlzz_xingyun" && entry.value("entry").toString()=="original/daily/xingyun.lua")
        config.insert("allow_spend",true);
}
}
