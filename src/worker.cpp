#include "bridge_protocol.hpp"
#include "core.hpp"
#include "task_permissions.hpp"
#include "builtin_resources.hpp"
#include "native_controller.hpp"
#include "gameplay_client.hpp"
#include "legacy_runner.hpp"
#include "resident_client.hpp"
#include "resident_vm.hpp"
#include "task_completion.hpp"
#include <QCoreApplication>
#include <QCryptographicHash>
#include <QDir>
#include <QFile>
#include <QDateTime>
#include <QElapsedTimer>
#include <QFileInfo>
#include <QFileSystemWatcher>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonParseError>
#include <QTimer>
#include <QWinEventNotifier>
#include <cmath>
#include <psapi.h>

namespace tlbb {
static QString option(const QStringList &args, const QString &key, const QString &fallback = {}) {
    int i = args.indexOf(key);
    return i >= 0 && i + 1 < args.size() ? args[i + 1] : fallback;
}
int runWorker(const QStringList &args) {
    auto *app = QCoreApplication::instance();
    const QString session = option(args, "--session"), root = option(args, "--game-root");
    const QString script = option(args, "--script");
    QString activeScript=script;
    bool waitMode=false;
    qint64 waitActiveMs=0,waitLastMs=0,waitPollMs=-500;
    QDateTime waitTarget;
    const auto dailyScript=QFileInfo(script).absolutePath()+"/legacy/daily_sign.lua";
    std::unique_ptr<LegacyRunner> legacy;
    std::unique_ptr<GameplayChannel> gameplayChannel;
    std::unique_ptr<ResidentChannel> residentChannel;
    bool residentMode=false;
    qint64 residentPollDue=0;
    QJsonObject residentState;
    bool dailyMode=false,dailyPending=false,dailySent=false,dailySeenVisible=false,dailyOpenAttempted=false;
    LegacyRequest dailyRequest;
    QJsonObject dailyState;
    qint64 dailyActiveMs=0,dailyLastMs=0,dailyQueryDue=0;
    unsigned dailyRewardMask=0;int dailyConfirmedSamples=0,dailyActions=0;
    const auto legacyDir=QFileInfo(script).absolutePath()+"/legacy";
    bool legacyMode=false,legacyPending=false,legacyMoving=false,legacyManualNoted=false,legacyCombat=false,legacyKillTask=false,legacyCombatBoss=false;
    int legacyCombatKills=0,legacyCombatRequests=0;
    LegacyRequest legacyRequest;QString legacyName,legacyLastLog;
    qint64 legacyActiveMs=0,legacyLastMs=0,legacyRetryAt=0;int legacyActions=0;
    ProcessBinding binding;
    HANDLE output = GetStdHandle(STD_OUTPUT_HANDLE), input = GetStdHandle(STD_INPUT_HANDLE);
    auto emitEvent = [&](QString type, QJsonObject body = QJsonObject{}) {
        body.insert("event", type);
        body.insert("session", session);
        QByteArray data = QJsonDocument(body).toJson(QJsonDocument::Compact) + "\n";
        if (data.size() > 32768)
            return;
        DWORD written = 0;
        if (!WriteFile(output, data.constData(), DWORD(data.size()), &written, nullptr))
            app->quit();
    };
    if (!binding.open(option(args, "--target-pid").toUInt(), root, option(args, "--created"),
                      args.contains("--test-target"))) {
        emitEvent("error", {{"message", binding.error}});
        return 2;
    }
    std::unique_ptr<LuaTask> task;
    LiveGameReader liveReader;
    QString liveError;
    const bool liveAvailable = liveReader.open(binding, liveError);
    bool liveMode = false, livePending = false;
    int liveActions = 0;
    QElapsedTimer motionProgress;
    double lastLiveX = 0, lastLiveY = 0;
    const QString bridgeDll = QCoreApplication::applicationDirPath() + "/TLBBEngine.dll";
    PreviewWorld preview;
    QJsonObject config, context;
    bool running = false, paused = false, reloadPending = false;
    QString lastDecision;
    QElapsedTimer taskTime;
    taskTime.start();
    auto cancelMotion = [&]() {
        // External combat tasks: auto-attack and chasing follow the target, so select ourselves first.
        bool attackStopped=true;
        if(legacyMode&&legacyCombat&&gameplayChannel&&binding.alive()){
            gameplay::SnippetArgs args{};SnippetReply reply;QString error;
            attackStopped=gameplayChannel->snippet(gameplay::SelfTarget,args,reply,error)&&reply.count>0&&reply.numbers[0]==1;
            emitEvent("decision",{{"kind","stop_attack"},{"preview",false},{"message",attackStopped?"已选中自身，停止攻击":"停止攻击未确认，请人工接管角色"}});
        }
        if (!((liveMode && livePending) || (legacyMode && legacyMoving)) || !binding.alive())
            return attackStopped;
        livePending = false;
        legacyMoving = false;
        QJsonObject state;
        QString error;
        if (!liveReader.snapshot(state, error)) {
            emitEvent("decision",{{"message","停止移动/攻击时角色状态不可读，请人工接管角色"}});
            return false;
        }
        auto cancelled =
            bridgeCommand(binding.info().pid, binding.info().created, root, bridgeDll, bridge::Move,
                          float(state.value("x").toDouble()), float(state.value("y").toDouble()));
        emitEvent("decision",
                  {{"kind", "cancel_move"},
                   {"preview", false},
                   {"message", cancelled.value("success").toBool() ? "已请求在当前位置停止移动"
                                                                   : "停止移动未确认，请人工接管角色"}});
        return attackStopped&&cancelled.value("success").toBool();
    };
    auto stop = [&](const QString &reason, bool failed = false) {
        residentChannel.reset();residentMode=false;residentState={};
        cancelMotion();
        running = false;
        paused = false;
        reloadPending = false;
        task.reset();
        legacy.reset();gameplayChannel.reset();dailyPending=false;
        legacyMode=false;legacyPending=false;
        context = {};
        emitEvent(failed ? "error" : "stopped", {{"message", reason}});
    };
    QWinEventNotifier targetExit(binding.handle());
    QObject::connect(&targetExit, &QWinEventNotifier::activated, app, [&]() {
        targetExit.setEnabled(false);
        stop("游戏进程已退出，对应脚本已停止");
        emitEvent("target_exited");
        app->quit();
    });
    auto reload = [&]() {
        QString error;
        try {
            auto candidate = std::make_unique<LuaTask>();
            if (!candidate->load(activeScript, error)) {
                emitEvent("reload_failed", {{"message", error}});
                return;
            }
            if (task && (task->schema != candidate->schema || task->id != candidate->id)) {
                emitEvent("reload_failed", {{"message", "任务上下文不兼容，旧版本保留"}});
                return;
            }
            task = std::move(candidate);
            emitEvent("reloaded", {{"version", task->version}, {"message", "Lua 已重载；兼容上下文保留"}});
        } catch (const std::exception &e) {
            emitEvent("reload_failed", {{"message", QString::fromUtf8(e.what())}});
        }
    };
    QFileSystemWatcher watcher;
    auto watch=[&](const QString &requested){const auto file=BuiltinResources::path(requested);if(!file.startsWith(':')&&QFileInfo::exists(file))watcher.addPath(file);};
    watch(script);watch(QFileInfo(script).absolutePath()+"/utility/wait_until.lua");watch(QFileInfo(script).absolutePath()+"/utility");watch(dailyScript);watch(QFileInfo(dailyScript).absolutePath());watch(QFileInfo(script).absolutePath());
    for(const auto &edited:{QCoreApplication::applicationDirPath()+"/overrides",QCoreApplication::applicationDirPath()+"/scripts"})if(QDir(edited).exists())watcher.addPath(edited);
    QTimer changed;
    changed.setSingleShot(true);
    changed.setInterval(300);
    QObject::connect(&watcher, &QFileSystemWatcher::fileChanged, app,
                     [&](const QString &) { changed.start(); });
    QObject::connect(&watcher, &QFileSystemWatcher::directoryChanged, app,
                     [&](const QString &) { changed.start(); });
    QObject::connect(&changed, &QTimer::timeout, app, [&]() {
        if (!watcher.files().contains(script) && QFileInfo::exists(script))
            watch(script);
        if(!watcher.files().contains(activeScript)&&QFileInfo::exists(activeScript))watch(activeScript);
        if(!watcher.files().contains(dailyScript)&&QFileInfo::exists(dailyScript))watch(dailyScript);
        emitEvent("script_changed", {{"message", "Lua 文件已变化，可点击重新加载"}});
    });
    QByteArray inbox;
    QTimer control;
    control.setInterval(50);
    QObject::connect(&control, &QTimer::timeout, app, [&]() {
        DWORD available = 0;
        if (!PeekNamedPipe(input, nullptr, 0, nullptr, &available, nullptr)) {
            stop("控制通道关闭");
            app->quit();
            return;
        }
        if (!available)
            return;
        char buffer[8192];
        DWORD read = 0;
        if (!ReadFile(input, buffer, qMin<DWORD>(available, sizeof(buffer)), &read, nullptr)) {
            app->quit();
            return;
        }
        inbox.append(buffer, int(read));
        if (inbox.size() > 65536) {
            emitEvent("error", {{"message", "控制消息超过上限"}});
            app->quit();
            return;
        }
        for (int count = 0; count < 16; ++count) {
            int newline = inbox.indexOf('\n');
            if (newline < 0)
                break;
            QByteArray line = inbox.left(newline);
            inbox.remove(0, newline + 1);
            QJsonParseError parse;
            auto document = QJsonDocument::fromJson(line, &parse);
            if (parse.error != QJsonParseError::NoError || !document.isObject())
                continue;
            auto command = document.object();
            if (command.value("session").toString() != session)
                continue;
            QString op = command.value("op").toString();
            if (op == "quit") {
                stop("会话已解绑");
                app->quit();
                return;
            }
            if (op == "stop") {
                stop("任务已停止");
                continue;
            }
            if (op == "pause") {
                if (running) {
                    if(residentMode){
                        QString e;QJsonObject state;
                        if(!residentChannel->command(paused?resident::Resume:resident::Pause,state,e)||state.value("state").toInt()==resident::Vm::Failed){stop(e.isEmpty()?state.value("error").toString():e,true);continue;}
                        residentState=state;paused=!paused;emitEvent("paused",{{"paused",paused}});continue;
                    }
                    if (!paused)
                        if(!cancelMotion()){stop("暂停时停止动作未确认，请人工接管",true);return;}
                    paused = !paused;
                    emitEvent("paused", {{"paused", paused}});
                }
                continue;
            }
            if (op == "reload") {
                if(residentMode&&running){emitEvent("reload_pending",{{"message","游戏内任务保持当前规则；新 Lua 在下次启动任务时加载"}});continue;}
                if(legacyMode&&running){emitEvent("reload_pending",{{"message","原脚本下次任务生效；当前任务保持原规则，避免重复提交"}});continue;}
                if(dailyMode){
                    if(running)emitEvent("reload_pending",{{"message","签到规则下次任务生效；当前任务保持原规则，避免重复提交"}});
                    else{LegacyRunner candidate;QString error;if(candidate.load(dailyScript,error))emitEvent("reloaded",{{"message","签到 Lua 已检查，下次任务加载新规则"}});else emitEvent("reload_failed",{{"message",error}});}
                    continue;
                }
                if (preview.pending() && running) {
                    reloadPending = true;
                    emitEvent("reload_pending", {{"message", "等待当前预演动作确认后重载"}});
                } else
                    reload();
                continue;
            }
            if (op != "start")
                continue;
            if (running) {
                emitEvent("error", {{"message", "当前任务尚在运行，请先停止"}});
                continue;
            }
            config = command.value("config").toObject();
            const QString mode = command.value("mode").toString();
            if (mode == "live_move" || (mode == "preview" && config.value("operation").toString() == "move"))
                config.insert("operation", "move");
            else
                config.remove("operation");
            QString error;
            if(mode=="daily_sign"){
                if(!validateDailySignConfig(config,error)){emitEvent("error",{{"message",error}});continue;}
                if(!liveAvailable){emitEvent("error",{{"message","签到需要已登录角色及已适配的真实状态"}});continue;}
                auto candidate=std::make_unique<LegacyRunner>();
                if(!candidate->load(dailyScript,error)){emitEvent("error",{{"message",error}});continue;}
                auto channel=std::make_unique<GameplayChannel>();QJsonObject initial;
                if(!channel->open(binding.info().pid,binding.info().created,root,error)||!channel->call(gameplay::Query,0,initial,error)){emitEvent("error",{{"message",error}});continue;}
                legacy=std::move(candidate);gameplayChannel=std::move(channel);task.reset();
                legacyMode=false;dailyMode=true;dailyPending=false;dailySent=false;dailySeenVisible=false;dailyOpenAttempted=false;dailyRewardMask=0;dailyConfirmedSamples=0;dailyActions=0;
                dailyActiveMs=0;dailyLastMs=0;dailyQueryDue=0;dailyState=initial;
                liveMode=false;livePending=false;waitMode=false;running=true;paused=false;reloadPending=false;lastDecision.clear();taskTime.restart();
                emitEvent("started",{{"mode",mode},{"message","开始执行原签到 Lua；等待游戏状态确认"}});continue;
            }
            if(mode=="legacy"){
                config=legacyDefaults(config);
                if(!validateLegacyConfig(config,error)){emitEvent("error",{{"message",error}});continue;}
                if(!liveAvailable){emitEvent("error",{{"message","原脚本任务需要已登录角色及已适配的真实状态"}});continue;}
                QJsonObject entry;QString path;
                if(!resolveLegacyEntry(legacyDir,config.value("legacy_id").toString(),entry,path,error)||!applyOriginalSourceChoice(legacyDir,config,entry,path,error)){emitEvent("error",{{"message",error}});continue;}
                if(entry.value("combat").toBool()!=config.value("combat").toBool()){emitEvent("error",{{"message","任务战斗能力与内置目录不符"}});continue;}
                applyTaskPermissions(entry,config);
                config.insert("validation_contract",entry.value("validation_contract"));
                if(config.value("engine").toString()!="外部兼容"){
                    const auto source=prepareResidentScript(legacyDir,path,config,error);
                    if(!error.isEmpty()){emitEvent("error",{{"message",error}});continue;}
                    auto channel=std::make_unique<ResidentChannel>();QJsonObject state;
                    if(!channel->open(binding.info().pid,binding.info().created,root,error)||!channel->start(source,config,state,error)){emitEvent("error",{{"message",error}});continue;}
                    residentChannel=std::move(channel);residentState=state;residentMode=true;residentPollDue=0;
                    legacy.reset();gameplayChannel.reset();task.reset();legacyMode=dailyMode=liveMode=livePending=waitMode=false;
                    legacyName=entry.value("name").toString();legacyCombat=entry.value("combat").toBool();legacyKillTask=entry.value("adapter").toString()=="combat_runtime_v1";
                    running=true;paused=false;reloadPending=false;taskTime.restart();
                    emitEvent("started",{{"mode",mode},{"backend","resident_lua54"},{"message","游戏内 Lua 已启动："+legacyName}});continue;
                }
                auto candidate=std::make_unique<LegacyRunner>();
                if(!candidate->load(path,error,legacyDir+"/compat.lua",config)){emitEvent("error",{{"message",error}});continue;}
                auto channel=std::make_unique<GameplayChannel>();QJsonObject initial;
                if(!channel->open(binding.info().pid,binding.info().created,root,error)||!channel->call(gameplay::Query,0,initial,error)){emitEvent("error",{{"message",error}});continue;}
                QFile source(path);QByteArray bytes;if(source.open(QIODevice::ReadOnly))bytes=source.readAll();
                const auto digest=QString::fromLatin1(QCryptographicHash::hash(bytes,QCryptographicHash::Sha256).toHex());
                const auto expected=entry.value("original_sha256").toString();
                legacy=std::move(candidate);gameplayChannel=std::move(channel);task.reset();
                legacyMode=true;legacyPending=false;legacyMoving=false;legacyManualNoted=false;legacyName=entry.value("name").toString();legacyLastLog.clear();
                legacyCombat=entry.value("combat").toBool();legacyKillTask=entry.value("adapter").toString()=="combat_runtime_v1";legacyCombatBoss=false;legacyCombatKills=0;legacyCombatRequests=0;
                legacyActiveMs=0;legacyLastMs=0;legacyRetryAt=0;legacyActions=0;
                dailyMode=false;liveMode=false;livePending=false;waitMode=false;running=true;paused=false;reloadPending=false;lastDecision.clear();taskTime.restart();
                emitEvent("started",{{"mode",mode},{"message",QString("开始执行原脚本：%1%2").arg(legacyName,!expected.isEmpty()&&expected!=digest?"（文件与原始哈希不同，按当前文件执行）":"")}});continue;
            }
            if (!(mode=="wait"?validateWaitConfig(config,error):validatePlantConfig(config, error))) {
                emitEvent("error", {{"message", error}});
                continue;
            }
            if (mode != "preview" && mode != "live_move" && mode != "wait") {
                emitEvent("blocked", {{"message", "真实种植尚不可用；可选择真实移动测试"},
                                      {"missing", QJsonArray::fromStringList(liveMissingCapabilities())}});
                continue;
            }
            if (mode == "live_move" && (!liveAvailable || !QFileInfo::exists(bridgeDll))) {
                emitEvent("error", {{"message", liveAvailable ? "缺少 TLBBEngine.dll" : liveError}});
                continue;
            }
            try {
                auto candidate = std::make_unique<LuaTask>();
                const auto candidateScript=mode=="wait"?QFileInfo(script).absolutePath()+"/utility/wait_until.lua":script;
                if (!candidate->load(candidateScript, error)) {
                    emitEvent("error", {{"message", error}});
                    continue;
                }
                if(candidate->id!=(mode=="wait"?"wait_until":"luoyang_plant")){
                    emitEvent("error",{{"message","Lua 任务标识与执行模式不符"}});continue;
                }
                task = std::move(candidate);
                dailyMode=false;legacyMode=false;legacy.reset();gameplayChannel.reset();dailyPending=false;
                activeScript=candidateScript;
                preview = PreviewWorld{};
                context = {};
                running = true;
                liveMode = mode == "live_move";
                waitMode=mode=="wait";waitActiveMs=0;waitLastMs=0;waitPollMs=-500;
                if(waitMode&&config.value("wait_kind").toString()=="指定时刻"){
                    const auto now=QDateTime::currentDateTime();waitTarget=now;
                    waitTarget.setTime(QTime::fromString(config.value("wait_time").toString(),"HH:mm"));
                    if(waitTarget<now)waitTarget=waitTarget.addDays(1);
                    config.insert("target_epoch_ms",double(waitTarget.toMSecsSinceEpoch()));
                }
                livePending = false;
                liveActions = 0;
                paused = false;
                reloadPending = false;
                lastDecision.clear();
                taskTime.restart();
                emitEvent("started", {{"mode", mode},
                                      {"version", task->version},
                                      {"message", waitMode ? "等待任务已开始" : liveMode ? "真实移动已开始；由 Lua 决策并核对真实位置"
                                                           : "流程预演已开始；不会操作游戏"}});
            } catch (const std::exception &e) {
                emitEvent("error", {{"message", QString::fromUtf8(e.what())}});
            }
        }
    });
    QTimer tick;
    tick.setInterval(100);
    QObject::connect(&tick, &QTimer::timeout, app, [&]() {
        if (!running)
            return;
        if(residentMode){
            if(taskTime.elapsed()<residentPollDue)return;
            residentPollDue=taskTime.elapsed()+500;QString error;QJsonObject state;
            if(!residentChannel->command(resident::Poll,state,error)){stop(error,true);return;}
            QStringList messages;state.insert("task_result",TaskCompletion::takeReceipt(state.value("log").toString(),messages));
            for(const auto &line:messages)emitEvent("decision",{{"kind","resident_log"},{"message",line}});
            residentState=state;
            const auto status=state.value("state").toInt();
            if(status==resident::Vm::Failed||status==resident::Vm::Stopped){stop(state.value("error").toString("游戏内任务已停止"),true);return;}
            if(status!=resident::Vm::Completed)return;
            const auto receipt=state.value("task_result").toObject();
            bool leftScene=false;
            if(config.value("legacy_id").toString()=="zhenlong_combat"){QJsonObject finalState;QString readError;leftScene=liveReader.snapshot(finalState,readError)&&finalState.value("scene_id").toInt()!=config.value("combat_scene").toInt();}
            const auto judgement=TaskCompletion::judge(TaskCompletion::facts(config,legacyCombat,legacyKillTask,state,leftScene));
            if(!judgement.accepted){stop(judgement.reason,true);return;}
            running=false;residentMode=false;residentChannel.reset();
            auto completed=TaskCompletion::completedEvent(judgement,receipt);completed.remove("event");
            const QJsonObject extra{{"message",receipt.isEmpty()?legacyName+" Lua 已执行结束；完成条件未单独核验":receipt.value("message").toString()},{"backend","resident_lua54"},{"native_calls",state.value("calls")},{"raw_calls",state.value("raw_calls")},{"control_ipc_requests",state.value("ipc_requests")},{"confirmed_kills",state.value("kills")},{"boss_confirmed",state.value("boss")},{"preview",false},{"operation",legacyCombat?"combat":"legacy"}};
            for(auto i=extra.begin();i!=extra.end();++i)completed.insert(i.key(),i.value());
            emitEvent("completed",completed);return;
        }
        if(dailyMode){
            const auto elapsed=taskTime.elapsed(),delta=elapsed-dailyLastMs;dailyLastMs=elapsed;
            if(paused)return;
            dailyActiveMs+=delta;
            if(dailyActiveMs>qint64(config.value("timeout_seconds").toInt(90))*1000){stop("签到结果未确认或等待超时；已停止且没有重发",true);return;} // running time only
            QString error;
            if(elapsed>=dailyQueryDue){
                dailyQueryDue=elapsed+500;
                if(!gameplayChannel||!gameplayChannel->call(gameplay::Query,0,dailyState,error)){stop(error,true);return;}
                dailySeenVisible|=dailyState.value("visible").toBool();
                const bool confirmed=dailySent&&dailySeenVisible&&dailyState.value("ready").toBool()&&dailyState.value("signed_today").toBool()&&dailyState.value("today").toInt()==QDate::currentDate().day();
                dailyConfirmedSamples=confirmed?dailyConfirmedSamples+1:0;
            }
            if(dailyState.value("manual").toBool()){
                if(lastDecision!="manual"){emitEvent("decision",{{"message","等待人工完成游戏验证"}});lastDecision="manual";}return;
            }
            if(dailySent&&!dailyState.value("visible").toBool()&&!dailyOpenAttempted){
                dailyOpenAttempted=true;gameplay::SnippetArgs args{};SnippetReply reply;
                if(!gameplayChannel->snippet(gameplay::OpenMonthlySign,args,reply,error)){stop("打开签到界面未确认："+error,true);return;}
                emitEvent("decision",{{"message",reply.count>0&&reply.numbers[0]==1?"已请求打开签到界面，等待状态确认":"无法自动打开签到界面，请手动打开以确认状态"}});
                dailyQueryDue=0;return;
            }
            if(!dailyPending){
                const auto progress=legacy->poll(dailyActiveMs,dailyRequest,error);
                if(progress==LegacyRunner::Failed){stop("签到 Lua："+error,true);return;}
                if(progress==LegacyRunner::Finished){
                    if(dailyConfirmedSamples<2)return;
                    int requested=0;for(int i=0;i<5;++i)requested+=(dailyRewardMask>>i)&1;
                    running=false;legacy.reset();gameplayChannel.reset();
                    emitEvent("completed",{{"verified",true},{"message",QString("今日签到状态已确认；累计奖励请求 %1 项").arg(requested)},
                        {"actions",dailyActions},{"signed_today_confirmed",true},{"reward_requests",requested},{"reward_items_confirmed",false},{"preview",false},{"operation","daily_sign"}});return;
                }
                if(progress==LegacyRunner::Waiting)return;
                dailyPending=true;
            }
            if(dailyRequest.command!=gameplay::DailySign&&dailyConfirmedSamples<1)return;
            if(dailyRequest.command==gameplay::ClaimMonthlyReward&&!dailyState.value("visible").toBool())return;
            if((dailyRequest.command==gameplay::DailySign&&dailySent)
                ||(dailyRequest.command==gameplay::ClaimMonthlyReward&&(dailyRewardMask&(1u<<(dailyRequest.argument-1))))){stop("规则产生重复签到或奖励请求，本次停止",true);return;}
            QJsonObject receipt;
            if(!gameplayChannel->call(dailyRequest.command,dailyRequest.argument,receipt,error)){
                legacy->acknowledge(dailyRequest.id,false,error);stop(error,true);return;
            }
            if(dailyRequest.command==gameplay::DailySign){dailySent=true;dailyConfirmedSamples=0;}
            if(dailyRequest.command==gameplay::ClaimMonthlyReward)dailyRewardMask|=1u<<(dailyRequest.argument-1);
            dailyActions+=receipt.value("actions").toInt();
            if(!legacy->acknowledge(dailyRequest.id,true)){stop("Lua 动作回执身份不符",true);return;}
            emitEvent("decision",{{"kind","legacy_game_call"},{"command",int(dailyRequest.command)},{"argument",dailyRequest.argument},{"actions",receipt.value("actions")},{"message",dailyRequest.command==gameplay::DailySign?"已提交一次今日签到，等待状态变化":dailyRequest.command==gameplay::ClaimMonthlyReward?QString("已按原规则提交第 %1 档累计奖励请求").arg(dailyRequest.argument):"签到窗口已关闭"}});
            dailyPending=false;dailyQueryDue=0;return;
        }
        if(legacyMode){
            const auto elapsed=taskTime.elapsed(),delta=elapsed-legacyLastMs;legacyLastMs=elapsed;
            if(paused)return;
            legacyActiveMs+=delta;
            if(legacyActiveMs>qint64(config.value("timeout_seconds").toInt(600))*1000){stop(legacyName+"：任务超时；已停止且没有重发",true);return;} // running time only, pauses excluded
            auto drain=[&]{for(const auto &line:legacy->takeMessages())if(line!=legacyLastLog){legacyLastLog=line;emitEvent("decision",{{"kind","legacy_log"},{"message",legacyName+"："+line}});}};
            QString error;
            if(!legacyPending){
                const auto progress=legacy->poll(legacyActiveMs,legacyRequest,error);drain();
                if(progress==LegacyRunner::Failed){stop(legacyName+"："+error,true);return;}
                if(progress==LegacyRunner::Finished){
                    TaskCompletion::FinishFacts facts;facts.contract=config.value("validation_contract").toString();
                    facts.combat=legacyCombat;facts.killTask=legacyKillTask;facts.chess=config.value("legacy_id").toString()=="zhenlong_combat";
                    facts.kills=legacyCombatKills;facts.killGoal=config.value("combat_kill_goal").toInt(1);facts.boss=legacyCombatBoss;
                    if(facts.chess){QJsonObject finalState;QString readError;facts.leftScene=liveReader.snapshot(finalState,readError)&&finalState.value("scene_id").toInt()!=config.value("combat_scene").toInt();}
                    const auto judgement=TaskCompletion::judge(facts);
                    if(!judgement.accepted){stop(judgement.reason,true);return;}
                    if(legacyCombat&&!cancelMotion()){stop("结束战斗时停止动作未确认，请人工接管",true);return;}
                    running=false;legacyMode=false;legacy.reset();gameplayChannel.reset();
                    emitEvent("completed",{{"verified",judgement.verified},{"message",legacyCombat?QString("%1 完成；确认目标死亡 %2 次%3").arg(legacyName).arg(legacyCombatKills).arg(legacyCombatBoss&&config.value("legacy_id").toString()=="zhenlong_combat"?"，远古棋魂死亡及离场已确认":""):QString("%1 已按原规则执行完毕；游戏动作 %2 次（结果以游戏内为准）").arg(legacyName).arg(legacyActions)},{"actions",legacyActions},{"confirmed_kills",legacyCombatKills},{"boss_confirmed",legacyCombatBoss},{"preview",false},{"operation",legacyCombat?"combat":"legacy"}});return;
                }
                if(progress==LegacyRunner::Waiting)return;
                legacyPending=true;
            }
            if(elapsed<legacyRetryAt)return;
            QVariantList values;
            if(legacyRequest.kind==LegacyRequest::Game){legacy->acknowledge(legacyRequest.id,false);stop("月度签到请求只在“每日签到”任务中执行",true);return;}
            if(legacyRequest.kind==LegacyRequest::Host){
                if(legacyRequest.host=="position"){
                    QJsonObject state;QString readError;
                    if(liveReader.snapshot(state,readError))values={true,state.value("scene_id").toInt(),state.value("x").toDouble(),state.value("y").toDouble(),state.value("map").toString()};
                    else values={false};
                }else if(legacyRequest.host=="stop_motion"){
                    if(!legacyCombat){stop("此任务没有战斗控制能力",true);return;}
                    if(!cancelMotion()){stop("停止移动/攻击未确认，请人工接管角色",true);return;}
                }else if(legacyRequest.host=="combat_result"){
                    if(!legacyCombat){stop("此任务没有战斗统计能力",true);return;}
                    if(legacyRequest.detail=="kill")++legacyCombatKills;
                    else if(legacyRequest.detail=="boss")legacyCombatBoss=true;
                    else {stop("战斗结果类型无效",true);return;}
                }else{
                    const auto window=reinterpret_cast<HWND>(gameplayChannel->window());
                    if(legacyRequest.detail=="flash"){FLASHWINFO flash{sizeof(FLASHWINFO),window,FLASHW_ALL|FLASHW_TIMERNOFG,5,0};FlashWindowEx(&flash);}else MessageBeep(MB_ICONEXCLAMATION);
                    emitEvent("decision",{{"kind","legacy_alert"},{"message",legacyName+(legacyRequest.detail=="flash"?"：已闪烁游戏窗口":"：已发出提示音")}});
                }
            }else{
                const bool action=gameplay::snippetIssuesAction(legacyRequest.snippet);
                const bool combatSnippet=legacyRequest.snippet>=gameplay::CombatScan&&legacyRequest.snippet<=gameplay::CombatName;
                if(combatSnippet&&!legacyCombat){stop("此任务未声明战斗能力",true);return;}
                if(combatSnippet&&++legacyCombatRequests>12000){stop("战斗查询超过 12000 次，已停止",true);return;}
                if(action&&legacyActions>=(legacyCombat?6000:600)){legacy->acknowledge(legacyRequest.id,false);stop(legacyName+"：游戏动作达到上限，已停止",true);return;}
                // Risky game steps need the task's own switch; the Lua side cannot grant it.
                const auto risk=gameplay::snippetRisk(legacyRequest.snippet,legacyRequest.args);
                if((risk&gameplay::RiskSpend)&&!config.value("allow_spend").toBool()){legacy->acknowledge(legacyRequest.id,false);stop(legacyName+"：此步骤会花费游戏币/交子/元宝，任务未开启“允许支付”，已停止",true);return;}
                if((risk&gameplay::RiskTransfer)&&!config.value("allow_transfer").toBool()){legacy->acknowledge(legacyRequest.id,false);stop(legacyName+"：此步骤会交易或转移物品/金钱，任务未开启“允许交易”，已停止",true);return;}
                if((risk&gameplay::RiskOffline)&&!config.value("allow_offline").toBool()){legacy->acknowledge(legacyRequest.id,false);stop(legacyName+"：此步骤会关闭游戏客户端（下线），任务未开启“允许下线”，已停止",true);return;}
                if((risk&gameplay::RiskSell)&&!config.value("allow_sell").toBool()){legacy->acknowledge(legacyRequest.id,false);stop(legacyName+"：此步骤会把物品卖给 NPC 商店，任务未开启“允许出售”，已停止",true);return;}
                if((risk&gameplay::RiskItem)&&!config.value("allow_item").toBool()){legacy->acknowledge(legacyRequest.id,false);stop(legacyName+"：此步骤会使用或移动物品，任务未开启“允许物品处理”，已停止",true);return;}
                if(legacyRequest.snippet==gameplay::CombatCast)legacyMoving=true;
                SnippetReply reply;
                if(!gameplayChannel->snippet(legacyRequest.snippet,legacyRequest.args,reply,error)){
                    if(reply.manual&&!reply.actions){
                        if(!legacyManualNoted){legacyManualNoted=true;emitEvent("decision",{{"message","等待人工完成游戏验证"}});}
                        legacyRetryAt=elapsed+1000;return;
                    }
                    legacy->acknowledge(legacyRequest.id,false,error);stop(legacyName+"："+error+(reply.actions?"（结果不确定，不会重发）":""),true);return;
                }
                legacyManualNoted=false;
                for(int i=0;i<reply.count;++i)values<<reply.numbers[i];
                if(!reply.text.isEmpty())values<<reply.text;
                if(action&&reply.count>0&&reply.numbers[0]>=1){
                    ++legacyActions;legacyMoving=legacyRequest.snippet==gameplay::RunTo||legacyRequest.snippet==gameplay::TalkNpc||legacyRequest.snippet==gameplay::CombatCast;
                    const auto &a=legacyRequest.args;const auto text=QString::fromWCharArray(a.text);QString message;
                    switch(legacyRequest.snippet){
                    case gameplay::CombatCast:message=a.ints[3]<0?"提交基础攻击":QString("提交技能：%1").arg(text);break;
                    case gameplay::RunTo:message=QString("提交寻路：场景 %1 (%2,%3)").arg(a.ints[0]).arg(a.reals[0]).arg(a.reals[1]);break;
                    case gameplay::TalkNpc:message=QString("寻路并对话：%1").arg(text);break;
                    case gameplay::NpcTarget:message=QString("对话 NPC：%1").arg(text);break;
                    case gameplay::QuestOption:message=QString("点击对话选项：%1").arg(reply.text.isEmpty()?text:reply.text);break;
                    case gameplay::QuestButton:message=a.ints[0]==1?"点击接受":a.ints[0]==2?"点击继续":"点击完成";break;
                    case gameplay::XScript:message=QString("提交游戏请求：%1").arg(QString::fromLatin1(gameplay::xscripts[a.ints[0]].function));break;
                    case gameplay::UiCall:message=QString("界面操作：%1").arg(QString::fromLatin1(gameplay::uiCalls[a.ints[0]].function));break;
                    case gameplay::UiEvent:message="打开界面";break;
                    case gameplay::BankBig:message="切换到大仓库界面";break;
                    case gameplay::BankMoney:message=QString("%1 %2 铜").arg(a.ints[0]==1?"仓库取钱":"仓库存钱").arg(reply.numbers[0]);break;
                    case gameplay::BankItem:message=QString("仓库取出：%1").arg(text);break;
                    case gameplay::BagStore:message=QString("存入仓库：%1").arg(text);break;
                    case gameplay::TempBag:message=a.ints[0]==1?QString("锦囊物品全部取出"):QString("锦囊取出：%1").arg(text);break;
                    case gameplay::SweepOpenPage:message=QString("打开扫荡页：副本 %1").arg(a.ints[0]);break;
                    case gameplay::SweepBoss:message=QString("扫荡选择首领 %1").arg(reply.numbers[0]);break;
                    case gameplay::ShopMoney:message=QString("商会取钱 %1 铜").arg(reply.numbers[0]);break;
                    case gameplay::GemCombine:message=QString("合成宝石：%1（%2 合 1）").arg(text).arg(a.ints[1]);break;
                    case gameplay::CloseNamed:message=QString("关闭界面：%1").arg(QString::fromLatin1(gameplay::closableWindows[a.ints[0]]));break;
                    default:message="关闭全部界面";break;
                    }
                    emitEvent("decision",{{"kind","legacy_game_call"},{"snippet",int(legacyRequest.snippet)},{"actions",legacyActions},{"message",legacyName+"："+message}});
                }else if(action&&legacyRequest.snippet!=gameplay::CombatCast)legacyMoving=false;
            }
            if(!legacy->acknowledge(legacyRequest.id,true,{},values)){stop("Lua 动作回执身份不符",true);return;}
            legacyPending=false;return;
        }
        if(waitMode){
            const auto elapsed=taskTime.elapsed(),delta=elapsed-waitLastMs;waitLastMs=elapsed;
            if(paused)return;
            waitActiveMs+=delta;
            if(elapsed-waitPollMs<500)return;
            waitPollMs=elapsed;
            if(elapsed>qint64(config.value("timeout_seconds").toInt())*1000){stop("等待任务超时",true);return;}
            const auto now=QDateTime::currentDateTime();
            const QJsonObject state{{"now_ms",double(now.toMSecsSinceEpoch())},{"active_elapsed_ms",double(waitActiveMs)}};
            Decision decision;QString error;
            if(!task||!task->step(state,config,context,decision,error)){stop("Lua 等待错误："+error,true);return;}
            context=decision.context;
            if(decision.kind=="complete"){
                const bool confirmed=config.value("wait_kind").toString()=="指定时刻"?now>=waitTarget:waitActiveMs>=qint64(config.value("wait_seconds").toInt())*1000;
                if(!confirmed){stop("等待时间尚未满足，已拒绝提前完成",true);return;}
                running=false;emitEvent("completed",{{"verified",true},{"message",decision.message},{"actions",0},{"preview",false},{"operation","wait"}});
            }else if(decision.kind=="error")stop(decision.message,true);
            else if(decision.kind!="wait")stop("等待脚本不能发起游戏动作",true);
            return;
        }
        if (liveMode) {
            if (taskTime.elapsed() > config.value("timeout_seconds").toInt(120) * 1000) {
                stop("真实移动任务超时", true);
                return;
            }
            if (paused)
                return;
            QJsonObject state;
            QString error;
            if (!liveReader.snapshot(state, error)) {
                stop(error, true);
                return;
            }
            const double x = state.value("x").toDouble(), y = state.value("y").toDouble();
            const double dx = x - config.value("x").toDouble(), dy = y - config.value("y").toDouble();
            const double tolerance = config.value("tolerance").toDouble();
            if (state.value("map").toString() != "洛阳") {
                stop("当前地图不是洛阳，已停止真实移动", true);
                return;
            }
            if (livePending && dx * dx + dy * dy > tolerance * tolerance) {
                if (std::abs(x - lastLiveX) + std::abs(y - lastLiveY) > 0.02) {
                    lastLiveX = x;
                    lastLiveY = y;
                    motionProgress.restart();
                }
                if (motionProgress.elapsed() < 1500)
                    return;
                livePending = false; // A manual interruption or obstruction requires a fresh Lua decision.
            } else
                livePending = false;
            Decision decision;
            if (!task || !task->step(state, config, context, decision, error)) {
                stop("Lua 错误：" + error, true);
                return;
            }
            context = decision.context;
            if (decision.kind == "move") {
                if (decision.x != config.value("x").toDouble() ||
                    decision.y != config.value("y").toDouble() || dx * dx + dy * dy > 32 * 32 ||
                    liveActions >= 3) {
                    stop("真实移动校验拒绝：目标必须一致且在 32 格内，每次任务最多提交三次", true);
                    return;
                }
                auto result = bridgeCommand(binding.info().pid, binding.info().created, root, bridgeDll,
                                            bridge::Move, float(decision.x), float(decision.y));
                livePending = result.value("game_actions_issued").toInt() != 0;
                if (!result.value("success").toBool() || !livePending) {
                    stop("移动调用失败：" + result.value("error").toString(), true);
                    return;
                }
                ++liveActions;
                motionProgress.restart();
                lastLiveX = x;
                lastLiveY = y;
                emitEvent(
                    "decision",
                    {{"kind", "move"},
                     {"preview", false},
                     {"state", state},
                     {"message",
                      QString("真实移动已提交：%1，%2；等待位置反馈").arg(decision.x).arg(decision.y)}});
            } else if (decision.kind == "complete") {
                if (dx * dx + dy * dy > tolerance * tolerance) {
                    stop("Lua 提前完成被拒绝：真实位置尚未到达", true);
                    return;
                }
                running = false;
                emitEvent("completed", {{"preview", false},{"verified",true},
                                        {"state", state},
                                        {"actions", liveActions},
                                        {"message", QString("真实移动完成：%1（%2，%3）")
                                                        .arg(state.value("map").toString())
                                                        .arg(x, 0, 'f', 2)
                                                        .arg(y, 0, 'f', 2)}});
            } else if (decision.kind == "plant" || decision.kind == "error")
                stop(decision.kind == "plant" ? "移动模式禁止种植动作" : decision.message, true);
            return;
        }
        preview.advance();
        if (reloadPending && !preview.pending()) {
            reloadPending = false;
            reload();
        }
        if (paused)
            return;
        if (taskTime.elapsed() > config.value("timeout_seconds").toInt(120) * 1000) {
            stop("任务超时", true);
            return;
        }
        if (preview.pending())
            return;
        Decision decision;
        QString error;
        if (!task || !task->step(preview.snapshot(), config, context, decision, error)) {
            stop("Lua 错误：" + error, true);
            return;
        }
        context = decision.context;
        if (decision.kind == "move" || decision.kind == "plant") {
            if (decision.kind == "move" &&
                (decision.x != config.value("x").toDouble() || decision.y != config.value("y").toDouble())) {
                stop("校验拒绝：脚本移动目标与面板配置不一致", true);
                return;
            }
            if (decision.kind == "plant") {
                auto snapshot = preview.snapshot();
                double dx = snapshot.value("x").toDouble() - config.value("x").toDouble(),
                       dy = snapshot.value("y").toDouble() - config.value("y").toDouble();
                double radius = config.value("tolerance").toDouble();
                if (dx * dx + dy * dy > radius * radius || decision.crop != config.value("crop").toString()) {
                    stop("校验拒绝：未到达位置或作物不匹配", true);
                    return;
                }
            }
            if (!preview.submit(decision, error)) {
                stop("校验拒绝：" + error, true);
                return;
            }
        }
        QString signature = decision.kind + decision.message;
        if (signature != lastDecision || decision.kind == "move" || decision.kind == "plant") {
            emitEvent("decision", {{"kind", decision.kind},
                                   {"message", decision.message},
                                   {"state", preview.snapshot()},
                                   {"preview", true}});
            lastDecision = signature;
        }
        if (decision.kind == "complete") {
            const bool movement = config.value("operation").toString() == "move";
            const auto state = preview.snapshot();
            const double dx = state.value("x").toDouble() - config.value("x").toDouble();
            const double dy = state.value("y").toDouble() - config.value("y").toDouble();
            const double tolerance = config.value("tolerance").toDouble();
            if (movement && dx * dx + dy * dy > tolerance * tolerance) {
                stop("校验拒绝：移动预演尚未确认到达目标", true);
                return;
            }
            if (!movement && state.value("planted_count").toInt() < config.value("rounds").toInt()) {
                stop("校验拒绝：尚未确认达到种植次数", true);
                return;
            }
            running = false;
            emitEvent("completed", {{"message", movement ? "移动预演完成，未操作游戏" : "种植预演完成，未操作游戏"},
                                    {"actions", preview.actions},
                                    {"state", preview.snapshot()},
                                    {"preview", true}});
        }
        if (decision.kind == "error")
            stop(decision.message, true);
    });
    QTimer heartbeat;
    heartbeat.setInterval(500);
    QObject::connect(&heartbeat, &QTimer::timeout, app, [&]() {
        PROCESS_MEMORY_COUNTERS_EX memory{};
        memory.cb = sizeof(memory);
        GetProcessMemoryInfo(GetCurrentProcess(), reinterpret_cast<PROCESS_MEMORY_COUNTERS *>(&memory),
                             sizeof(memory));
        QJsonObject liveState;
        QString error;
        const bool positionValid = liveAvailable && liveReader.snapshot(liveState, error);
        if(!residentState.value("battle").toObject().isEmpty())liveState.insert("battle",residentState.value("battle"));
        emitEvent("heartbeat", {{"running", running},
                                {"paused", paused},
                                {"live_position_available", positionValid},
                                {"live_state", liveState},
                                {"backend",residentMode?"resident_lua54":"external"},
                                {"lua_bytes", residentMode?residentState.value("lua_bytes").toDouble():double(task ? task->allocated() : legacy ? legacy->allocated() : 0)},
                                {"private_commit_bytes", double(memory.PrivateUsage)}});
    });
    control.start();
    tick.start();
    heartbeat.start();
    emitEvent("ready", {{"header_readable", binding.headerReadable},
                        {"live_position_available", liveAvailable},
                        {"pid", int(binding.info().pid)},
                        {"message", liveAvailable ? "真实位置读取已就绪；支持洛阳近距离移动，种植待适配"
                                                  : "只读绑定就绪；" + liveError}});
    int result = app->exec();
    targetExit.setEnabled(false);
    task.reset();
    return result;
}
} // namespace tlbb
