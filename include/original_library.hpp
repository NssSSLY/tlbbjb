#pragma once
#include "builtin_resources.hpp"
#include "legacy_runner.hpp"
#include <QCryptographicHash>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QDateTime>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QSet>
#include <functional>
#include <cmath>
extern "C" {
#include <lauxlib.h>
}
namespace tlbb {
// Original scripts run from the decompiled source in scripts/original-source (tools/import-original-source.py
// compares every file with the original bytecode function by function before it is shipped).
// The source is compiled here and sent stripped, the same form the extracted bytecode used to take.
inline bool originalSourceChunk(const QString &directory,const QString &token,QByteArray &chunk,QString &error){
    chunk.clear();error.clear();const auto base=QDir::cleanPath(directory+"/../original-source");
    // Cached per resolved file and its size/time, so an edited or newly added override index takes effect
    // at the next task start (with the scripts it lists) instead of rejecting them against stale hashes.
    static QJsonObject cached;static QString cachedStamp;
    const auto indexPath=BuiltinResources::path(base+"/index.json");const QFileInfo info(indexPath);
    const auto stamp=indexPath+'|'+QString::number(info.size())+'|'+QString::number(info.lastModified().toMSecsSinceEpoch());
    if(cachedStamp!=stamp){
        QFile f(indexPath);
        if(!f.open(QIODevice::ReadOnly)||f.size()>1024*1024){error="原脚本源码索引缺失或过大";return false;}
        const auto index=QJsonDocument::fromJson(f.readAll()).object();
        if(index.value("schema").toInt()!=1||index.value("kind").toString()!="tlbb_original_source"){error="原脚本源码索引无效";return false;}
        cached=index.value("modules").toObject();cachedStamp=stamp;
    }
    const auto m=cached.value(token).toObject();const auto name=m.value("name").toString(token);
    if(m.isEmpty()){error="原脚本源码缺失："+token;return false;}
    const auto path=BuiltinResources::child(base,m.value("path").toString());QFile f(path);
    if(path.isEmpty()||!f.open(QIODevice::ReadOnly)||f.size()>1024*1024){error="原脚本源码文件缺失："+name;return false;}
    auto source=f.readAll();
    if(QCryptographicHash::hash(source,QCryptographicHash::Sha256).toHex()!=m.value("sha256").toString().toLatin1()){error="原脚本源码校验失败："+name;return false;}
    source=LegacyRunner::translateSource(source,error);if(!error.isEmpty())return false;
    lua_State *L=luaL_newstate();if(!L){error="内存不足，无法编译原脚本源码";return false;}
    const auto label=("=original/"+name).toUtf8();
    if(luaL_loadbufferx(L,source.constData(),size_t(source.size()),label.constData(),"t")!=LUA_OK){
        error="原脚本源码语法错误（"+name+"）："+QString::fromUtf8(lua_tostring(L,-1));lua_close(L);return false;}
    lua_dump(L,[](lua_State*,const void *p,size_t n,void *ud){static_cast<QByteArray*>(ud)->append(static_cast<const char*>(p),qsizetype(n));return 0;},&chunk,1);
    lua_close(L);if(chunk.isEmpty()){error="原脚本源码编译失败："+name;return false;}return true;
}
inline QJsonObject originalLibraryIndex(const QString &directory,QString &error){
    error.clear();QFile f(BuiltinResources::path(QDir::cleanPath(directory+"/../original-library/index.json")));
    if(!f.open(QIODevice::ReadOnly)||f.size()>512*1024){error="原 Lua 模块索引缺失或过大";return {};}
    const auto index=QJsonDocument::fromJson(f.readAll()).object();const auto modules=index.value("modules").toArray();
    if(index.value("schema").toInt()!=1||modules.isEmpty()||modules.size()>512){error="原 Lua 模块索引无效";return {};}
    auto all=modules;for(const auto &v:index.value("custom_sources").toArray())all.append(v);
    if(all.size()>512){error="原 Lua 与源码总数超过限制";return {};}
    QSet<QString> tokens;
    for(const auto &v:all){const auto token=v.toObject().value("token").toString();
        if(token.size()!=8||tokens.contains(token)){error="原 Lua 模块标识重复或无效";return {};}
        for(const QChar c:token)if(!(c>='0'&&c<='9')&&!(c>='a'&&c<='f')){error="原 Lua 模块标识无效";return {};}
        tokens.insert(token);
    }
    return index;
}
// Only the selected chunk and its literal module closure enter the per-task VM.
// The full archive remains in the uncompressed resource and is never extracted.
inline bool originalRuleClosure(const QString &directory,const QString &selected,QJsonObject &chunks,QJsonObject &names,QString &error){
    chunks={};names={};const auto index=originalLibraryIndex(directory,error);if(!error.isEmpty())return false;
    QJsonObject records,aliases;
    auto modules=index.value("modules").toArray();for(const auto &v:index.value("custom_sources").toArray())modules.append(v);
    for(const auto &v:modules){const auto m=v.toObject();records.insert(m.value("token").toString(),m);aliases.insert(m.value("name").toString(),m.value("token"));}
    QSet<QString> visiting;qsizetype total=0;
    std::function<bool(const QString&)> add=[&](const QString &token){
        if(visiting.contains(token)){error="原 Lua 模块依赖循环";return false;}
        if(chunks.contains(token))return true;
        const auto m=records.value(token).toObject();if(m.isEmpty()){error="原 Lua 模块不存在："+token;return false;}
        if(m.value("known_empty_stub").toBool()){error="原 Lua 是空壳，没有实际任务逻辑："+m.value("name").toString();return false;}
        if(chunks.size()>=32){error="单任务原 Lua 依赖超过 32 个";return false;}
        QByteArray data;if(!originalSourceChunk(directory,token,data,error))return false;
        total+=data.size();if(total>256*1024){error="单任务原 Lua 编译后超过 256 KiB";return false;}
        visiting.insert(token);chunks.insert(token,QString::fromLatin1(data.toBase64()));names.insert(m.value("name").toString(),token);
        for(const auto &load:m.value("literal_modules").toArray()){
            auto name=load.toString();if(name.endsWith(".lua"))name.chop(4);
            if(aliases.contains(name)&&!add(aliases.value(name).toString()))return false;
        }
        visiting.remove(token);return true;
    };
    if(!add(selected)){chunks={};names={};return false;}return true;
}
}
