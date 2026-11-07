#pragma once
#include "builtin_resources.hpp"
#include "legacy_runner.hpp"
#include "feature_plan.hpp"
#include "profile_config.hpp"
#include "original_library.hpp"
#include <QCryptographicHash>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <stdexcept>
namespace tlbb {
template<class Test>void resourceTests(const QString &root,Test test){
    test("original_library_complete_hashes_and_bounded_task_closure",[&]{
        auto must=[](bool v,const char *why){if(!v)throw std::runtime_error(why);};QString error;
        const auto dir=":/tlbb/scripts/builtin/legacy";const auto index=originalLibraryIndex(dir,error);must(error.isEmpty(),qPrintable(error));
        const auto modules=index.value("modules").toArray();must(modules.size()==318,"Original module library is incomplete");
        QSet<QString> tokens;for(const auto &v:modules){const auto m=v.toObject();tokens.insert(m.value("token").toString());
            QFile shard(root+"/scripts/original-library/"+m.value("shard").toString());must(shard.open(QIODevice::ReadOnly),"Original shard missing");
            must(shard.seek(m.value("offset").toInt()),"Original chunk seek failed");const auto data=shard.read(m.value("bytes").toInt());
            must(data.startsWith("\x1bLua\x54")&&QCryptographicHash::hash(data,QCryptographicHash::Sha256).toHex()==m.value("sha256").toString().toLatin1(),"Original library chunk hash mismatch");
            must(m.value("numeric_and_control_flow_unchanged").toBool()&&!m.value("rules_rewritten").toBool(),"Original library altered task instructions");
        }
        must(tokens.size()==318,"Duplicate original module identity");QJsonObject chunks,names;
        const auto custom=index.value("custom_sources").toArray();must(custom.size()==36,"Plain Lua sources were not all imported");int occurrences=0;QString example;
        for(const auto &v:custom){const auto m=v.toObject();occurrences+=m.value("sources").toArray().size();
            QFile f(root+"/scripts/original-library/"+m.value("shard").toString());must(f.open(QIODevice::ReadOnly)&&f.seek(m.value("offset").toInt()),"Plain source archive missing");
            must(QCryptographicHash::hash(f.read(m.value("bytes").toInt()),QCryptographicHash::Sha256).toHex()==m.value("original_sha256").toString().toLatin1(),"Plain source bytes changed");
            if(m.value("name").toString()=="自定义·窗口闪烁报警")example=m.value("token").toString();
        }
        must(occurrences==72&&!example.isEmpty(),"Source duplicates or plain Lua provenance lost");
        must(originalRuleClosure(dir,example,chunks,names,error)&&chunks.size()==1,"Plain Lua cannot use the bounded module loader");
        must(originalRuleClosure(dir,"0043a061",chunks,names,error)&&chunks.size()==1&&names.value("使用金纹铜钱").toString()=="0043a061","Task loaded unrelated original modules");
        must(!originalRuleClosure(dir,"002ac35d",chunks,names,error)&&chunks.isEmpty()&&error.contains("空壳"),"Empty shop stub was treated as a functioning task");
        must(!originalRuleClosure(dir,"../bad",chunks,names,error)&&chunks.isEmpty(),"Invalid original token accepted");
        QJsonObject entry;QString path;must(resolveLegacyEntry(dir,"jinwen",entry,path,error)&&entry.value("validation_contract").toString()=="jinwen_inventory_v1","New task is not wired to original execution");
        must(!resolveLegacyEntry(dir,"pet_shop",entry,path,error),"Stub task entered the execution manifest");
        // Shards are project evidence only; the release bundle carries the index and original-source.
        must(!QFile::exists(":/tlbb/scripts/builtin/original-library/rules-00.bin")&&QFile::exists(":/tlbb/scripts/builtin/original-library/index.json"),"Bytecode shards shipped in the release bundle");
    });
    test("resource_bundle_integrity_and_generic_dungeon_contracts",[&]{
        auto must=[](bool v,const char *why){if(!v)throw std::runtime_error(why);};
        const auto report=BuiltinResources::report();must(report.value("mounted").toBool(),"Resource bundle not mounted");
        const auto entries=report.value("files").toArray();must(entries.size()>100&&entries.size()<1024,"Resource manifest incomplete");
        for(const auto &v:entries){const auto o=v.toObject();const auto key=o.value("path").toString();
            QFile built(":/tlbb/"+key);must(built.open(QIODevice::ReadOnly),"Bundled entry unreadable");
            auto source=key.startsWith("scripts/builtin/")?root+"/scripts/"+key.mid(16):root+"/design/task-catalog.json";
            QFile f(source);must(f.open(QIODevice::ReadOnly),"Resource source missing");
            must(built.readAll()==f.readAll(),"Bundled resource differs from source");
        }
        const QString dir=":/tlbb/scripts/builtin/legacy";
        must(BuiltinResources::child(dir,"../data/reference_routes.json").isEmpty(),"Escaping entry accepted");
        must(BuiltinResources::child(dir,"C:/Windows/win.ini").isEmpty(),"Absolute entry accepted");
        for(const auto &id:{"battle_inspect","dungeon_combat","zhenlong_combat"}){QJsonObject entry;QString path,error;
            must(resolveLegacyEntry(dir,id,entry,path,error),qPrintable(error));must(path.startsWith(":/tlbb/"),"Unmodified entry was extracted to disk");
        }
        QJsonObject absent;QString path,error;must(!resolveLegacyEntry(dir,"not_a_task",absent,path,error),"Unknown task dispatched");
        QFile combat(root+"/scripts/legacy/combat.lua");must(combat.open(QIODevice::ReadOnly),"Combat source missing");const auto code=combat.readAll();
        must(!code.contains("RunZhenlongDungeon")&&!code.contains("远古棋魂")&&!code.contains("张弈国"),"Common combat depends on chess encounter");
        QFile registry(":/tlbb/scripts/builtin/dungeons/catalog.json");must(registry.open(QIODevice::ReadOnly),"Dungeon registry missing");
        const auto modules=QJsonDocument::fromJson(registry.readAll()).object().value("entries").toArray();must(modules.size()==32,"Provided dungeon modules not all registered");
        int enabled=0;for(const auto &v:modules){const auto d=v.toObject();enabled+=d.value("runtime_enabled").toBool()?1:0;
            QFile chunk(":/tlbb/scripts/builtin/dungeons/"+d.value("resource").toString());must(chunk.open(QIODevice::ReadOnly),"Original dungeon chunk was not bundled");
            const auto bytes=chunk.readAll();must(bytes.startsWith("\x1bLua\x54"),"Imported rule has wrong Lua ABI");
            must(QCryptographicHash::hash(bytes,QCryptographicHash::Sha256).toHex()==d.value("resource_sha256").toString().toLatin1(),"Original dungeon resource hash mismatch");
            must(d.value("bytecode_proof").toObject().value("numeric_and_control_flow_unchanged").toBool()&&!d.value("rules_rewritten").toBool(),"Original dungeon rule changed during import");
        }
        must(enabled==1,"Source inventory was mislabeled as executable dungeon support");
    });
    test("requested_feature_plan_sources_priorities_and_execution_boundary",[&]{
        auto must=[](bool v,const char *why){if(!v)throw std::runtime_error(why);};
        QFile planFile(":/tlbb/scripts/builtin/planning/feature-plan.json");must(planFile.open(QIODevice::ReadOnly),"Feature plan resource missing");
        const auto plan=QJsonDocument::fromJson(planFile.readAll()).object();const auto features=plan.value("features").toArray();
        must(plan.value("requested_group_count").toInt()==56&&features.size()==88,"User feature request coverage changed");
        must(plan.value("source_dungeon_count").toInt()==32&&plan.value("new_executable_tasks").toInt()==0,"Planning enabled unverified tasks");
        QFile cat(":/tlbb/tasks/catalog.json");must(cat.open(QIODevice::ReadOnly),"Feature catalog missing");const auto tasks=QJsonDocument::fromJson(cat.readAll()).object().value("tasks").toArray();
        const QStringList priority{"shimen","child_parents","pet_sell_npc","pet_shop","pet_comprehension","fish_process","dali_flower","xunying","jiuli_clear","fixed_rebels","grab_box"};
        must(plan.value("priority_task_order").toArray().size()==priority.size(),"Explicit priority task lost");
        for(const auto &id:priority){const auto t=plannedTask(tasks,id);
            must(t.value("plan_priority").toString()=="P0","Explicit priority lost its P0 label");
            QJsonObject entry;QString path,error;const bool runnable=resolveLegacyEntry(":/tlbb/scripts/builtin/legacy",id,entry,path,error);
            if(t.value("generic_original").toBool()){
                // Runs the original script source unchanged until a dedicated flow replaces it; completion stays unverified.
                must(runnable&&entry.value("adapter").toString()=="original_generic_v1"&&!entry.value("live_verified").toBool()
                     &&t.value("adapter_status").toString()=="integrated_pending_live"&&!t.contains("planning_only"),"Priority task runs original source without its contract");
                continue;
            }
            if(runnable&&!entry.value("validation_contract").toString().isEmpty()&&!entry.value("live_verified").toBool())continue; // Dedicated flow with a completion contract.
            must(t.value("planning_only").toBool(),"Explicit priority mislabeled executable");
            must(taskAdapterLabel(t)=="优先待接入"&&!plannedTaskReason(t).isEmpty(),"Planned task lacks an honest readiness reason");
            must(!runnable,"Staged bytecode became executable without an adapter");
            for(const auto &v:t.value("settings").toArray())must(v.toObject().value("key").toString().startsWith("plan_"),"Draft setting masquerades as a mapped original parameter");
        }
        int staged=0;for(const auto &v:plan.value("modules").toArray()){const auto m=v.toObject();if(!m.contains("resource"))continue;++staged;
            QFile rule(":/tlbb/scripts/builtin/planning/"+m.value("resource").toString());must(rule.open(QIODevice::ReadOnly),"Priority original Lua missing");const auto bytes=rule.readAll();
            must(bytes.startsWith("\x1bLua\x54")&&QCryptographicHash::hash(bytes,QCryptographicHash::Sha256).toHex()==m.value("resource_sha256").toString().toLatin1(),"Priority rule hash or Lua ABI changed");
            must(m.value("bytecode_proof").toObject().value("numeric_and_control_flow_unchanged").toBool()&&!m.value("runtime_enabled").toBool(),"Planning rewrote or enabled an original task");
        }
        must(staged==11,"Priority original modules were not staged separately");
        must(!plannedTask(tasks,"plant").value("planning_only").toBool(),"Existing planting preview was disabled by the future planting script");
        QJsonObject draftTasks;for(const auto &v:tasks)draftTasks.insert(v.toObject().value("id").toString(),QJsonObject{{"plan_rounds",1}});
        QJsonObject imported;QString error;
        must(readPortableProfile(portableProfile({{"tasks",draftTasks}}),imported,error)&&imported.value("tasks").toObject().size()==tasks.size(),"Full catalog configuration cannot be imported");
        for(int i=draftTasks.size();i<=512;++i)draftTasks.insert(QString("overflow_%1").arg(i),QJsonObject{});
        must(!readPortableProfile(portableProfile({{"tasks",draftTasks}}),imported,error),"Task draft count lost its memory bound");
    });
}
}
