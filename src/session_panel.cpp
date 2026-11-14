#include "session_panel.hpp"
#include "feature_plan.hpp"
#include "original_library.hpp"
#include "client_store.hpp"
#include "route_catalog.hpp"
#include "profile_config.hpp"
#include "ui_styles.hpp"
#include <QApplication>
#include <QCheckBox>
#include <QCloseEvent>
#include <QComboBox>
#include <QDialog>
#include <QDialogButtonBox>
#include <QDoubleSpinBox>
#include <QFile>
#include <QFormLayout>
#include <QGridLayout>
#include <QGroupBox>
#include <QHeaderView>
#include <QImage>
#include <QLabel>
#include <QLineEdit>
#include <QListWidget>
#include <QPlainTextEdit>
#include <QPushButton>
#include <QPointer>
#include <QSaveFile>
#include <QScrollArea>
#include <QToolButton>
#include <QTimeEdit>
#include <QSignalBlocker>
#include <QSpinBox>
#include <QTableWidget>
#include <QTabWidget>
#include <QUuid>
#include <QVBoxLayout>
#include <QWindow>

namespace tlbb {
static QString taskName(const QJsonArray &catalog, const QString &id) {
    for (const auto &v : catalog) if (v.toObject().value("id").toString() == id) return v.toObject().value("name").toString();
    return id;
}
SessionPanel::SessionPanel(GameInfo target, QJsonObject data) : QWidget(nullptr, Qt::Window), game(target), profile_(migrateTaskProfile(data)) {
    setAttribute(Qt::WA_DeleteOnClose, false);
    setWindowTitle(QString("%1 · 任务面板").arg(game.pid));
    setFont(QFont("Microsoft YaHei UI", 9));
    resize(1120, 710); setMinimumSize(1000, 620);
    setStyleSheet(QStringLiteral("QWidget{background:#f3f5f7;color:#1e2c3d;} QLabel{background:transparent;} QGroupBox{border:1px solid #ccd5e0;margin-top:8px;padding:10px;background:white;} QGroupBox::title{subcontrol-origin:margin;left:8px;padding:0 4px;} QLineEdit,QComboBox,QSpinBox,QDoubleSpinBox,QPlainTextEdit,QTableWidget,QListWidget{background:white;border:1px solid #c9d2df;padding:4px;} QPushButton{background:white;border:1px solid #c9d2df;border-radius:3px;padding:5px 9px;} QPushButton:disabled{color:#8995a5;} QTabWidget::pane{border:0;} QTabBar::tab{padding:8px 11px;background:white;border:1px solid #d1d9e3;} QTabBar::tab:selected{background:#e0f0f1;color:#096d77;border-bottom:2px solid #146e78;}") + checkboxStyleSheet());
    catalog_ = ClientStore::readJson(QCoreApplication::applicationDirPath()+"/tasks/catalog.json").value("tasks").toArray();
    if (catalog_.isEmpty()) catalog_ = QJsonArray{QJsonObject{{"id","plant"},{"name","种植"},{"category","生活"},{"family","plant"}}};
    if (!profile_.contains("tasks")) profile_.insert("tasks",QJsonObject{});
    if (!profile_.contains("queue")) profile_.insert("queue",QJsonArray{});
    normalizeOriginalTasks();
    build();
    // A standalone window: an owned one always stays above the game and minimizes with it.
}
QJsonObject SessionPanel::profile() const { return profile_; }
SessionPanel::~SessionPanel(){tearingDown_=true;}
void SessionPanel::normalizeOriginalTasks(){
    // Change only the execution mode of entries that now load original chunks.
    auto saved=profile_.value("tasks").toObject();
    for(const auto &v:catalog_){const auto task=v.toObject();if(!task.value("requires_resident").toBool())continue;
        const auto id=task.value("id").toString();if(saved.contains(id)){auto p=saved.value(id).toObject();p.insert("engine","游戏内 Lua");saved.insert(id,p);}
        for(const auto key:{"queue","scheduled"}){auto nodes=profile_.value(key).toArray();for(int i=0;i<nodes.size();++i){auto n=nodes[i].toObject();if(n.value("task").toString()!=id)continue;auto p=n.value("params").toObject();p.insert("engine","游戏内 Lua");n.insert("params",p);nodes[i]=n;}profile_.insert(key,nodes);}
    }
    profile_.insert("tasks",saved);
}
QJsonObject SessionPanel::parameters(const QString &id) const {
    bool combatTask=false;for(const auto &v:catalog_)if(v.toObject().value("id").toString()==id)combatTask=v.toObject().value("combat").toBool();
    QJsonObject p{{"x",360},{"y",317},{"map","洛阳"},{"crop","小麦"},{"rounds",1},
        {"tolerance",0.3},{"timeout_seconds",120},{"retries",2},{"failure","停止队列"},
        {"difficulty","普通"},{"method","完整通关"},{"team","已有队伍"},{"budget",0},
        {"route",""},{"target",""},{"minutes",30},{"radius",20},{"resource",""},
        {"window",""},{"wait_seconds",20},{"growth","早产"},{"harvest","播种并收获"},
        {"attack_mode",id=="pvp"?"跟随队长":"先抢后清"},{"locate_mode","多点巡刷"},{"target_order",id=="pvp"?"队长目标,攻击本队玩家,名单玩家":"队长目标,任务目标,附近怪物"},
        {"heal_percent",60},{"heal_skills",""},
        {"pickup",false},{"pet_supply",false},{"follow_radius",5},{"neutral_players",false},
        {"mode",id=="luoyang_move"?"live_move":"live"}};
    if(id=="wait"){p.insert("wait_kind","指定时刻");p.insert("wait_time","20:05");p.insert("timeout_seconds",90000);}
    if(id=="daily_sign"){p.insert("timeout_seconds",90);p.insert("mode","daily_sign");}
    for(const auto &t:catalog_)if(t.toObject().value("id").toString()==id&&t.toObject().value("family").toString()=="legacy"){
        p.insert("mode","legacy");p.insert("legacy_id",id);p.insert("timeout_seconds",t.toObject().value("timeout_seconds").toInt(600));
        // A failed or stuck reference task ends with a reason; by default the queue moves on to the next task.
        p.insert("failure","跳过本项");
        p.insert("engine","游戏内 Lua");
        const auto engines=t.toObject().value("supported_engines").toArray();if(!engines.isEmpty())p.insert("engine",engines.first());
        if(t.toObject().contains("original_bindings"))p.insert("original_bindings",t.toObject().value("original_bindings"));
        // Risk switches default to off; the Worker refuses the matching steps until enabled.
        for(const auto &risk:t.toObject().value("risks").toArray())p.insert("allow_"+risk.toString(),false);
        // Catalog-declared settings reach the script as TaskConfig.<key>.
        for(const auto &v:t.toObject().value("settings").toArray())p.insert(v.toObject().value("key").toString(),v.toObject().value("default"));
    }
    if(combatTask){
        p.insert("combat",true);p.insert("combat_scene",3);p.insert("combat_radius",45);p.insert("combat_min_hp",25);
        p.insert("combat_interval_ms",1000);p.insert("combat_stall_seconds",60);p.insert("combat_kill_goal",1);
        p.insert("combat_skills","");p.insert("entry_mode","自动入场");
    }
    for(const auto &t:catalog_)if(t.toObject().value("id").toString()==id&&t.toObject().value("planning_only").toBool()){
        p.insert("mode","planned");
        for(const auto &v:t.toObject().value("settings").toArray())p.insert(v.toObject().value("key").toString(),v.toObject().value("default"));
    }
    auto stored=profile_.value("tasks").toObject().value(id).toObject();
    for(auto i=stored.begin();i!=stored.end();++i)p.insert(i.key(),i.value());
    for(const auto &t:catalog_){const auto task=t.toObject();if(task.value("id").toString()!=id)continue;const auto engines=task.value("supported_engines").toArray();
        if(!engines.isEmpty()&&!engines.contains(p.value("engine")))p.insert("engine",engines.first());}
    // A promoted task may still have a saved planning draft. Use its real entry
    // for a new invocation, without silently converting old queue snapshots.
    for(const auto &t:catalog_){const auto task=t.toObject();if(task.value("id").toString()==id&&task.value("family").toString()=="legacy"&&p.value("mode").toString()=="planned"){
        p.insert("mode","legacy");p.insert("legacy_id",id);p.insert("engine","游戏内 Lua");}}
    if(id=="zhenlong_combat")p.insert("combat_scene",61);
    if(id=="yanzi"){
        p.insert("combat_scene",236);
        if(p.value("yzw_type").toString().isEmpty())p.insert("yzw_type","普通");
        if(!stored.contains("yanzi_kill_wyy")&&stored.contains("xzk119"))p.insert("yanzi_kill_wyy",stored.value("xzk119"));
    }
    if(id=="guanshan")p.insert("combat_scene",749);
    if(id=="invasion")p.insert("combat_scene",170);
    if(id=="qianbai"||id=="chuge"||id=="yuhua"||id=="wujian"||id=="orig_00445fe7"||id=="orig_00446737"||id=="orig_0044eec5"||id=="orig_0044d295"||id=="orig_00454fcd"||id=="orig_00456501"||id=="orig_004486c3"||id=="orig_00449e91")p.insert("combat_scene",1079);
    if(id=="xiaoaci"||id=="orig_0045a610"||id=="orig_0045b8d6")p.insert("combat_scene",1072);
    if(id=="xiakexing")p.insert("combat_scene",1017);
    if(id=="dungeon_002eb7bd")p.insert("combat_scene",268);
    if(id=="dungeon_0031bd09")p.insert("combat_scene",233);
    if(id=="dungeon_002b9e15")p.insert("combat_scene",269);
    if(id=="dungeon_002ee7ae")p.insert("combat_scene",300);
    if(id=="dungeon_00301bdf"||id=="dungeon_0030129e"||id=="dungeon_002ff923")p.insert("combat_scene",877);
    if(id=="dungeon_00322b14"||id=="dungeon_0032b023")p.insert("combat_scene",999);
    if(id=="dungeon_002e1e29")p.insert("combat_scene",848);
    if(id=="dungeon_002cfcf9")p.insert("combat_scene",934);
    if(id=="dungeon_0031c749")p.insert("combat_scene",231);
    if(id=="dungeon_0031db5f")p.insert("combat_scene",232);
    if(id=="sanshen"||id=="dungeon_002fd257")p.insert("combat_scene",662);
    if(id=="wangling"||id=="dungeon_002fd8cc")p.insert("combat_scene",600);
    if(id=="langhuan"||id=="dungeon_002fe064"){
        p.insert("combat_scene",677);
        if(id=="langhuan"&&p.value("lhfd_type").toString().isEmpty())p.insert("lhfd_type","普通");
    }
    if(id=="bingsheng"){
        p.insert("combat_scene",294);
        if(p.value("bingsheng_mode").toString().isEmpty())p.insert("bingsheng_mode","简单");
        if(p.value("bingsheng_twin").toString().isEmpty())p.insert("bingsheng_twin","按分队");
    }
    if(id=="piaomiao"){
        p.insert("combat_scene",261);
        if(p.value("dpmf_type").toString().isEmpty())p.insert("dpmf_type","普通");
    }
    if(id=="shaoshi"){
        p.insert("combat_scene",566);
        if(p.value("sss_type").toString().isEmpty())p.insert("sss_type","普通");
    }
    if(id=="dungeon_002fbdb4")p.insert("combat",true); // Repair saved drafts from the old non-combat declaration.
    if(id=="sijue"){
        p.insert("combat_scene",291);
        if(p.value("sjz_type").toString().isEmpty())p.insert("sjz_type","普通");
        if(!stored.contains("sijue_bell_role")&&stored.value("Boss1不敲钟").toBool())p.insert("sijue_bell_role","其他队友");
        if(!stored.contains("sijue_diagonal")&&stored.contains("Boss2跑对角"))p.insert("sijue_diagonal",stored.value("Boss2跑对角"));
        if(!stored.contains("sijue_columns")&&stored.contains("Boss4不跑龙柱"))p.insert("sijue_columns",!stored.value("Boss4不跑龙柱").toBool());
        if(!stored.contains("sijue_blind_share")&&stored.contains("Boss2分担失明"))p.insert("sijue_blind_share",stored.value("Boss2分担失明"));
    }
    if(id=="zhenlong_combat"&&stored.value("engine").toString()=="外部兼容"&&!stored.contains("rule_source"))p.insert("rule_source","兼容重建");
    if(combatTask){
        const auto battle=profile_.value("battle").toObject();
        if(p.value("combat_skills").toString().trimmed().isEmpty())p.insert("combat_skills",battle.value("skills").toString().replace('\n',','));
        if(!stored.contains("combat_interval_ms"))p.insert("combat_interval_ms",battle.value("cooldown_ms").toInt(1000));
        auto system=battle;system.insert("enabled",battle.value("enabled").toBool(true));p.insert("battle_system",system);
    }
    return p;
}
QWidget *SessionPanel::editor(const QString &id, QJsonObject values, std::function<void(QJsonObject)> changed) {
    auto *container=new QWidget; auto *outer=new QVBoxLayout(container); outer->setContentsMargins(0,0,0,0);
    QString family;QJsonObject metadata;
    for(const auto &t:catalog_)if(t.toObject().value("id").toString()==id){metadata=t.toObject();family=metadata.value("family").toString();}
    auto *group=new QGroupBox(taskName(catalog_,id)+" · "+taskAdapterLabel(metadata));
    auto *grid=new QGridLayout(group);grid->setAlignment(Qt::AlignTop);
    for(int column=0;column<3;++column)grid->setColumnStretch(column,1);
    auto data=std::make_shared<QJsonObject>(values); int cell=0,advancedCell=0;
    auto *advanced=new QWidget(group);auto *advancedGrid=new QGridLayout(advanced);advancedGrid->setContentsMargins(0,0,0,0);advanced->hide();
    auto add=[&](const QString &key,const QString &label,QStringList options={},bool number=false,double minimum=0,double maximum=10000,QGridLayout *target=nullptr,int *targetCell=nullptr) {
        auto *box=new QWidget; auto *layout=new QVBoxLayout(box);layout->setContentsMargins(0,0,0,0);layout->setSpacing(3);
        QString caption=label;
        if(key=="gulanyu_list")caption="兑换清单";
        else if(key=="qianxin_items")caption="兑换物品";
        else if(key=="shop_items")caption="物品清单";
        else if(key=="voucher_gem3")caption="3 级兑换券的宝石";
        else if(key=="voucher_gem4")caption="4 级兑换券的宝石";
        auto *captionLabel=new QLabel(caption);captionLabel->setWordWrap(true);captionLabel->setToolTip(label);layout->addWidget(captionLabel);
        auto write=[this,data,key,changed](QJsonValue value){if(tearingDown_)return;data->insert(key,value);changed(*data);};
        const auto savedTime=QTime::fromString(data->value(key).toString(),"HH:mm");
        if(key=="wait_time"&&savedTime.isValid()){
            auto *time=new QTimeEdit(savedTime);time->setObjectName(id+"_"+key);time->setDisplayFormat("HH:mm");time->setToolTip("选择本地时间，24 小时制");layout->addWidget(time);
            connect(time,&QTimeEdit::timeChanged,container,[write](const QTime &value){write(value.toString("HH:mm"));});
        }else if(!options.isEmpty()) {
            auto *c=new QComboBox;c->setObjectName(id+"_"+key);
            for(const auto &option:options)c->addItem(option.isEmpty()?QString("未设置"):option,option);
            const auto saved=data->value(key);const auto value=saved.isString()?saved.toString():options.first();
            int selected=c->findData(value);if(selected<0){c->addItem(value.isEmpty()?QString("未设置"):value+"（已保存）",value);selected=c->count()-1;}
            c->setCurrentIndex(selected);layout->addWidget(c);
            if(key=="engine")c->setToolTip("游戏内 Lua：可信脚本直接调用游戏 API。允许支付/交易开关只约束兼容接口，无法拦截任意直调代码。外部兼容：沿用固定调用检查。");
            connect(c,&QComboBox::currentIndexChanged,container,[write,c](int){write(c->currentData().toString());});
            if(key=="engine"&&options.size()==1){box->setParent(group);box->hide();return;}
        }else if(number){auto *spin=new QDoubleSpinBox;spin->setDecimals(key=="tolerance"?1:0);spin->setRange(minimum,maximum);spin->setValue(data->value(key).toDouble());spin->setObjectName(id+"_"+key);if(key=="retries")spin->setEnabled(false);layout->addWidget(spin);connect(spin,&QDoubleSpinBox::valueChanged,container,[write](double v){write(v);});}
        else {auto *edit=new QLineEdit(data->value(key).toString());edit->setMaxLength(key=="sanhuan_route"?1024:key=="combat_skills"?600:128);edit->setObjectName(id+"_"+key);
            QString hint;
            if(key=="加入门派")hint="例如：逍遥 天山；未匹配时原规则随机选择";
            else if(key=="练级等级")hint="填写目标等级，例如：40";
            else if(key=="voucher_gem3"||key=="voucher_gem4")hint="填写对话选项中的宝石名称，例如：红宝石；留空不兑换";
            else if(key=="combat_skills")hint="例如：技能甲,技能乙；留空沿用技能页";
            else if(key=="sanhuan_route")hint="留空读取任务坐标；例：100,120;110,130|150,180（分号分点，竖线分组，每组最多 24 点）";
            else if(key=="sanhuan_exit_npc")hint="填写副本内离场 NPC 完整名称；留空读取任务的返回坐标";
            else if(key=="enter_option")hint="留空自动匹配入场选项；手填游戏对话中的完整选项原文";
            else if(key=="leave_option")hint="填写离场 NPC 对话中的完整选项原文，与离场 NPC 配合使用";
            else if(key=="wait_time")hint="例如：08:30（24 小时制）";
            else if(key=="gulanyu_list")hint="例如：红宝石|5 黄玉|3，项目用空格分隔";
            else if(key=="shop_items"&&label.contains("数量"))hint="例如：物品甲*2 物品乙*1，项目用空格分隔";
            else if(label.contains("空格分隔"))hint="例如：名称甲 名称乙，多个项目用空格分隔";
            else if(key.startsWith("bjk")||key.startsWith("lbk")||key.startsWith("dxk")||key.startsWith("xzk"))hint="原规则参数：含义待核对，建议保留已保存值";
            else if(key=="map"||key=="plan_map")hint="请输入游戏内地图名称，例如：洛阳";
            else if(key=="crop")hint="请输入作物的游戏内名称";
            else if(label.contains("逗号分隔"))hint="例如：技能甲,技能乙";
            else hint="按游戏内显示的完整名称或规则填写";
            edit->setPlaceholderText(hint);edit->setToolTip(hint);layout->addWidget(edit);connect(edit,&QLineEdit::textChanged,container,[write](const QString &v){write(v);});}
        auto *destination=target?target:grid;int &index=targetCell?*targetCell:cell;
        destination->addWidget(box,index/3,index%3);++index;
    };
    auto addSettings=[&]{
        for(const auto &t:catalog_)if(t.toObject().value("id").toString()==id)for(const auto &v:t.toObject().value("settings").toArray()){
            const auto o=v.toObject();const auto type=o.value("type").toString();const auto key=o.value("key").toString();const auto label=o.value("label").toString();
            const bool opaque=!label.isEmpty()&&label.at(0).isLetter()&&label.at(0).unicode()<128&&(label==key||label.contains("（"+key+"）"));
            auto *destination=opaque?advancedGrid:grid;int &index=opaque?advancedCell:cell;
            if(id=="orig_00267ca1"&&(key=="购买定位"||key=="制作定位"))continue;
            if(type=="bool"){
                auto *check=new QCheckBox(label);check->setObjectName(id+"_"+key);check->setChecked(data->value(key).toBool());
                if(o.contains("source_key"))check->setToolTip("原配置："+o.value("source_section").toString()+" / "+o.value("source_key").toString());
                if(opaque)check->setToolTip("原规则参数，具体用途尚未核对；已保存的值会保留。");
                destination->addWidget(check,index/3,index%3);++index;
                connect(check,&QCheckBox::toggled,container,[this,data,changed,key](bool on){if(tearingDown_)return;data->insert(key,on);changed(*data);});
            }else{
                QStringList choices;for(const auto &c:o.value("choices").toArray())choices<<c.toString();
                add(key,label,choices,type=="number",o.value("min").toDouble(0),o.value("max").toDouble(10000),destination,&index);
            }
        }
        if(advancedCell){
            auto *more=new QToolButton;more->setText("原参数（用途待核对）");more->setCheckable(true);more->setArrowType(Qt::RightArrow);more->setToolButtonStyle(Qt::ToolButtonTextBesideIcon);
            const int row=(cell+2)/3;grid->addWidget(more,row,0,1,3);grid->addWidget(advanced,row+1,0,1,3);cell=(row+2)*3;
            connect(more,&QToolButton::toggled,container,[more,advanced](bool on){advanced->setVisible(on);more->setArrowType(on?Qt::DownArrow:Qt::RightArrow);});
        }else delete advanced;
    };
    if(metadata.value("planning_only").toBool()){
        group->setTitle(group->title()+"（参数草稿）");group->setToolTip(plannedTaskReason(metadata));
        addSettings();outer->addWidget(group);
        outer->addStretch();
        return container;
    }
    if(family=="legacy"){
        const bool resident=metadata.value("requires_resident").toBool();
        if(resident)data->insert("engine","游戏内 Lua");
        QStringList engines;for(const auto &e:metadata.value("supported_engines").toArray())engines<<e.toString();
        if(engines.isEmpty())engines=resident?QStringList{"游戏内 Lua"}:QStringList{"游戏内 Lua","外部兼容"};
        add("engine","执行引擎",engines);
    }
    if(id=="luoyang_move"||id=="plant"){add("map","地图");add("x","目标 X",{},true);add("y","目标 Y",{},true);}
    if(id=="plant"){add("crop","作物");add("growth","生长类型",{"早产","晚产"});add("harvest","执行阶段",{"播种并收获","仅播种","仅收获"});add("wait_seconds","空地复查 / 秒",{},true,2,300);}
    if(id=="luoyang_move")add("tolerance","到达容差",{},true,0.1,2);
    if(family=="dungeon"){add("difficulty","难度",{"普通","困难"});add("method","执行方式",{"完整通关","游戏内扫荡"});add("team","队伍",{"已有队伍","等待指定队伍"});}
    if(family=="daily"||family=="cargo"){add("route","任务分支 / 路线");add("budget","购买预算",{},true,0,1000000);}
    if(family=="timed"){add("window","允许时段");add("team","队伍",{"已有队伍","等待指定队伍"});}
    if(family=="grind"||family=="gather"||family=="treasure"){add("map","地图");add("target","目标 / 资源");add("route","地点 / 路线");add("minutes","持续分钟",{},true,1,1440);}
    if(family=="grind"){add("attack_mode","打怪模式",{"先抢后清","打死换怪","珍兽单刷","跟随队长"});add("locate_mode","定位方式",{"单点刷怪","多点巡刷","跟随队长"});add("radius","定位范围",{},true,1,100);add("target_order","目标优先级（逗号分隔）");add("monster_allowlist","指定怪物名单");add("pet_name","出战珍兽");}
    if(family=="pvp"){add("attack_mode","打架模式",{"跟随队长","原地反击","名单目标"});add("target_order","敌人检测顺序");add("player_allowlist","指定玩家名单");add("player_blocklist","保护玩家名单");add("guild_allowlist","指定帮会 ID");add("follow_radius","跟随范围",{},true,1,100);}
    if(family=="heal"){add("target_order","加血对象顺序");add("heal_percent","血量低于 %",{},true,1,100);add("heal_skills","加血技能顺序");}
    if(family=="trade"||family=="progression"){add("budget","单轮支出上限",{},true,0,1000000);add("target","物品 / 操作目标");add("confirm","确认方式",{"等待人工","按规则核对（待适配）"});}
    if(id=="wait"){
        add("wait_kind","等待方式",{"指定时刻","等待时长"});add("wait_time","本地时刻 HH:mm");
        add("wait_seconds","等待时长 / 秒",{},true,1,86400);add("timeout_seconds","最长等待 / 秒",{},true,1,90000);
        auto *kind=group->findChild<QComboBox*>(id+"_wait_kind");auto *clock=group->findChild<QWidget*>(id+"_wait_time");auto *duration=group->findChild<QWidget*>(id+"_wait_seconds");
        auto updateWait=[kind,clock,duration]{const bool byTime=kind&&kind->currentData().toString()=="指定时刻";if(clock)clock->parentWidget()->setVisible(byTime);if(duration)duration->parentWidget()->setVisible(!byTime);};
        if(kind)connect(kind,&QComboBox::currentIndexChanged,container,[updateWait](int){updateWait();});
        updateWait();
    }else if(id=="daily_sign"){
        add("timeout_seconds","任务超时 / 秒",{},true,10,300);
    }else if(family=="legacy"&&(id=="dungeon_combat"||id=="zhenlong_combat")){
        if(id=="zhenlong_combat")add("entry_mode","入场方式",{"自动入场","已在副本"});
        else {add("combat_scene","副本场景 ID",{},true,0,4095);add("combat_kill_goal","确认击杀数",{},true,1,500);}
        add("combat_skills","输出技能（逗号分隔；留空沿用技能页）");
        add("combat_radius","战斗范围 / 格",{},true,3,60);add("combat_min_hp","血量低于 % 停止",{},true,1,95);
        add("combat_interval_ms","技能最小间隔 / 毫秒",{},true,750,5000);
        add("combat_stall_seconds","生命无变化超时 / 秒",{},true,10,300);add("timeout_seconds","任务超时 / 秒",{},true,10,7200);
        addSettings();
        if(id=="zhenlong_combat"){
            auto *source=group->findChild<QComboBox*>(id+"_rule_source");auto *entry=group->findChild<QComboBox*>(id+"_entry_mode");
            auto *quick=group->findChild<QCheckBox*>(id+"_original_quick_mode");auto *count=group->findChild<QDoubleSpinBox*>(id+"_original_team_count");
            auto update=[source,entry,quick,count]{const bool active=source&&entry&&source->currentText()=="原规则"&&entry->currentText()=="自动入场";if(quick)quick->setEnabled(active);if(count)count->setEnabled(active);};
            if(source)connect(source,&QComboBox::currentTextChanged,container,[update]{update();});
            if(entry)connect(entry,&QComboBox::currentTextChanged,container,[update]{update();});
            update();
        }
    }else if(family=="legacy"){
        add("timeout_seconds","任务超时 / 秒",{},true,10,7200);
        addSettings();
        QString scope;for(const auto &t:catalog_)if(t.toObject().value("id").toString()==id)scope=t.toObject().value("source_scope").toString();
        if(!scope.isEmpty()){
            auto *details=new QToolButton;details->setText("任务说明");details->setCheckable(true);details->setArrowType(Qt::RightArrow);details->setToolButtonStyle(Qt::ToolButtonTextBesideIcon);
            auto *note=new QLabel(scope);note->setWordWrap(true);note->setStyleSheet("color:#5b6b7f;");note->hide();
            grid->addWidget(details,(cell+2)/3+1,0,1,3);grid->addWidget(note,(cell+2)/3+2,0,1,3);
            connect(details,&QToolButton::toggled,container,[note,details](bool on){note->setVisible(on);details->setArrowType(on?Qt::DownArrow:Qt::RightArrow);});
        }
    }else{
        add("rounds","次数 / 轮数",{},true,1,100);add("timeout_seconds","任务超时 / 秒",{},true,10,(id=="plant"||id=="luoyang_move")?1800:3600);
    }
    add("failure","失败处理",{"停止队列","跳过本项","等待人工"});
    if(id=="plant"||id=="luoyang_move") {
        auto *modeBox=new QWidget;auto *modeLayout=new QVBoxLayout(modeBox);modeLayout->setContentsMargins(0,0,0,0);modeLayout->addWidget(new QLabel("运行方式"));auto *mode=new QComboBox;
        mode->addItem(id=="luoyang_move"?"真实移动":"真实种植（待适配）",id=="luoyang_move"?"live_move":"live");mode->addItem("流程预演（不操作游戏）","preview");mode->setCurrentIndex(qMax(0,mode->findData(data->value("mode").toString())));modeLayout->addWidget(mode);grid->addWidget(modeBox,cell/3,cell%3);
        connect(mode,&QComboBox::currentIndexChanged,container,[this,data,changed,mode]{if(tearingDown_)return;data->insert("mode",mode->currentData().toString());changed(*data);});
    }
    auto *formScroll=new QScrollArea;formScroll->setObjectName(id+"_parameter_scroll");formScroll->setWidgetResizable(true);formScroll->setFrameShape(QFrame::NoFrame);formScroll->setWidget(group);outer->addWidget(formScroll,1);
    if(family=="legacy"){
        QJsonArray risks=metadata.value("risks").toArray();
        for(const auto &r:QStringList{"spend","transfer","sell","item"})if(!risks.contains(r))risks.append(r);
        auto *permissions=new QGroupBox("动作选项");auto *riskGrid=new QGridLayout(permissions);int riskCell=0,extraCell=0;
        auto *moreButton=new QToolButton;moreButton->setText("其他动作选项");moreButton->setCheckable(true);moreButton->setArrowType(Qt::RightArrow);moreButton->setToolButtonStyle(Qt::ToolButtonTextBesideIcon);
        auto *extra=new QWidget;auto *extraGrid=new QGridLayout(extra);extraGrid->setContentsMargins(0,0,0,0);extra->hide();
        connect(moreButton,&QToolButton::toggled,container,[moreButton,extra](bool on){extra->setVisible(on);moreButton->setArrowType(on?Qt::DownArrow:Qt::RightArrow);});
        const auto declared=metadata.value("risks").toArray();
        for(const auto &risk:risks){
            if((id=="tlzz_wish_1001"&&risk.toString()=="item")||((id=="tlzz_xingyun"||id=="orig_00267ca1")&&risk.toString()=="spend"))continue;
            const auto key="allow_"+risk.toString();
            const QString label=risk.toString()=="spend"?"允许支付":risk.toString()=="transfer"?"允许交易":risk.toString()=="offline"?"允许下线":risk.toString()=="sell"?"允许出售":risk.toString()=="item"?"允许物品处理（使用、仓库、锦囊）":"允许："+risk.toString();
            auto *check=new QCheckBox(label);check->setObjectName(id+"_"+key);check->setChecked(data->value(key).toBool());
            check->setToolTip("只约束本程序已分类的兼容调用；GetLuaValue 直调目前无法全面识别，不能作为全部原规则的保护。");
            if(declared.contains(risk)){riskGrid->addWidget(check,riskCell/2,riskCell%2);++riskCell;}
            else {extraGrid->addWidget(check,extraCell/2,extraCell%2);++extraCell;}
            connect(check,&QCheckBox::toggled,container,[this,data,changed,key](bool on){if(tearingDown_)return;data->insert(key,on);changed(*data);});
        }
        if(extraCell){const int row=(riskCell+1)/2;riskGrid->addWidget(moreButton,row,0,1,2);riskGrid->addWidget(extra,row+1,0,1,2);}else {delete moreButton;delete extra;}
        if(riskCell||extraCell)outer->addWidget(permissions);else delete permissions;
    }
    if(family=="grind"||family=="pvp"){
        auto *options=new QGroupBox("辅助规则 · 待适配");auto *row=new QGridLayout(options);int at=0;
        const QList<QPair<QString,QString>> fields=family=="grind"?QList<QPair<QString,QString>>{{"pickup","自动拾取"},{"pet_supply","珍兽补给"},{"avoid_claimed","跳过已归属目标"},{"return_anchor","回到定位点"}}:QList<QPair<QString,QString>>{{"follow_attack","跟随队长目标"},{"retaliate","反击攻击本队的玩家"},{"neutral_players","允许攻击中立玩家"},{"respawn_wait","死亡后等待人工"}};
        for(const auto &item:fields){auto *check=new QCheckBox(item.second);check->setChecked(data->value(item.first).toBool());row->addWidget(check,at/3,at%3);++at;connect(check,&QCheckBox::toggled,container,[this,data,changed,key=item.first](bool on){if(tearingDown_)return;data->insert(key,on);changed(*data);});}outer->addWidget(options);
    }
    if(id=="stall"||family=="trade"){auto *manage=new QPushButton("管理物品 / 上架规则");outer->addWidget(manage);connect(manage,&QPushButton::clicked,container,[this,id]{selectTab("物品");if(auto *tabs=findChild<QTabWidget*>("itemTabs"))tabs->setCurrentIndex(id=="stall"?4:5);});}
    if(family=="grind"||family=="gather"||family=="treasure") {
        auto *routesBox=new QGroupBox("参考路线");auto *row=new QHBoxLayout(routesBox);
        auto *choices=new QComboBox;choices->setObjectName(id+"_reference_route");choices->addItem("不使用参考路线");
        auto *preview=new QPushButton("坐标预览");preview->setObjectName(id+"_route_preview");
        auto *summary=new QLabel;row->addWidget(choices,1);row->addWidget(summary);row->addWidget(preview);
        QJsonArray routes;QString routeError;
        const bool loaded=RouteCatalog::load(QCoreApplication::applicationDirPath()+"/scripts/builtin/data/reference_routes.json",routes,routeError);
        QJsonArray extraRoutes;QString extraError;
        if(RouteCatalog::load(QCoreApplication::applicationDirPath()+"/scripts/builtin/data/tlzz_reference_routes.json",extraRoutes,extraError))for(const auto &route:extraRoutes)routes.append(route);
        const auto selected=data->value("reference_route").toObject();
        int selectedIndex=0;
        for(int i=0;i<routes.size();++i){const auto route=routes[i].toObject();const auto prefix=route.value("source").toObject().value("pack")=="tlzz"?QString("天龙助手 · "):QString();choices->addItem(prefix+route.value("name").toString(),route.value("id"));if(route.value("id")==selected.value("id")&&route.value("source").toObject().value("sha256")==selected.value("source_sha256"))selectedIndex=i+1;}
        choices->setCurrentIndex(selectedIndex);choices->setEnabled(loaded);
        auto describe=[choices,preview,summary,routes,loaded,routeError,data] {
            const int index=choices->currentIndex()-1;preview->setEnabled(index>=0&&index<routes.size());
            summary->setText(index>=0?QString("%1 点 · 未核对").arg(routes[index].toObject().value("points").toArray().size()):(!data->value("reference_route").toObject().isEmpty()?"原引用不可用，请重新选择":""));
            if(!loaded){summary->setText("路线库不可用");summary->setToolTip(routeError);}
        };
        describe();
        connect(choices,&QComboBox::currentIndexChanged,container,[this,data,changed,choices,routes,describe,container,id](int i){
            if(tearingDown_)return;
            if(i>0&&i<=routes.size()){
                const auto route=routes[i-1].toObject();data->insert("reference_route",RouteCatalog::reference(route));
                data->insert("route",route.value("name"));
                if(auto *edit=container->findChild<QLineEdit*>(id+"_route")){const QSignalBlocker blocker(edit);edit->setText(route.value("name").toString());}
            }else data->remove("reference_route");
            changed(*data);describe();
        });
        auto previewWindow=std::make_shared<QPointer<QDialog>>();
        connect(preview,&QPushButton::clicked,container,[choices,routes,container,previewWindow]{
            const int index=choices->currentIndex()-1;if(index<0||index>=routes.size())return;
            if(*previewWindow){(*previewWindow)->close();}
            const auto route=routes[index].toObject();const auto points=route.value("points").toArray();
            auto *dialog=new QDialog(container);dialog->setAttribute(Qt::WA_DeleteOnClose);dialog->setWindowTitle(route.value("name").toString()+" · 参考坐标");dialog->resize(480,520);
            *previewWindow=dialog;
            auto *layout=new QVBoxLayout(dialog);auto *hint=new QLabel("地图线索："+route.value("map_hint").toString()+" · 用途待核对");layout->addWidget(hint);
            auto *table=new QTableWidget(points.size(),4);table->setObjectName("reference_route_points");table->setHorizontalHeaderLabels({"序号","X","Y","来源行"});table->setEditTriggers(QAbstractItemView::NoEditTriggers);table->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
            for(int n=0;n<points.size();++n){const auto p=points[n].toObject();table->setItem(n,0,new QTableWidgetItem(QString::number(n+1)));table->setItem(n,1,new QTableWidgetItem(QString::number(p.value("x").toDouble())));table->setItem(n,2,new QTableWidgetItem(QString::number(p.value("y").toDouble())));table->setItem(n,3,new QTableWidgetItem(QString::number(p.value("source_line").toInt())));}
            layout->addWidget(table);auto *close=new QDialogButtonBox(QDialogButtonBox::Close);close->button(QDialogButtonBox::Close)->setText("关闭");layout->addWidget(close);connect(close,&QDialogButtonBox::rejected,dialog,&QDialog::close);dialog->show();
        });
        outer->addWidget(routesBox);
    }
    outer->addStretch();return container;
}
void SessionPanel::addLegacyTask(const QString &id) {
    auto q=profile_.value("queue").toArray();if(q.size()>=64){status_->setText("任务流程最多 64 项");return;}
    q.append(QJsonObject{{"node_id",QUuid::createUuid().toString(QUuid::WithoutBraces)},{"task",id},{"enabled",true},{"params",parameters(id)}});profile_.insert("queue",q);refreshQueue();
    status_->setText("已加入此游戏的任务流程");
}
QWidget *SessionPanel::taskPage(const QString &category) {
    auto *page=new QWidget;auto *layout=new QHBoxLayout(page);layout->setContentsMargins(8,8,8,8);
    auto *list=new QListWidget;list->setMaximumWidth(170);list->setMinimumWidth(130);layout->addWidget(list);
    for(const auto &v:catalog_){auto t=v.toObject();if(t.value("category").toString()==category){auto *item=new QListWidgetItem(t.value("name").toString(),list);item->setData(Qt::UserRole,t.value("id"));}}
    auto *right=new QWidget;auto *rightLayout=new QVBoxLayout(right);rightLayout->setContentsMargins(0,0,0,0);layout->addWidget(right,1);
    auto update=[this,list,rightLayout,right] {
        if(tearingDown_)return;
        while(auto *item=rightLayout->takeAt(0)){if(item->widget())item->widget()->deleteLater();delete item;}
        if(!list->currentItem())return;
        QString id=list->currentItem()->data(Qt::UserRole).toString();
        rightLayout->addWidget(editor(id,parameters(id),[this,id](QJsonObject p){auto tasks=profile_.value("tasks").toObject();tasks.insert(id,p);profile_.insert("tasks",tasks);}),1);
        auto *buttons=new QHBoxLayout;auto *add=new QPushButton("加入任务流程"),*run=new QPushButton("运行本项");buttons->addWidget(add);buttons->addWidget(run);buttons->addStretch();rightLayout->addLayout(buttons);
        connect(add,&QPushButton::clicked,right,[this,id]{addTask(id);});connect(run,&QPushButton::clicked,right,[this,id]{if(runRequested)runRequested(QJsonArray{QJsonObject{{"task",id},{"enabled",true},{"params",parameters(id)}}});});
    };
    connect(list,&QListWidget::currentRowChanged,page,[update](int){update();});if(list->count())list->setCurrentRow(0);
    return page;
}
QWidget *SessionPanel::legacyRulePage(const QString &section) {
    auto *page=new QWidget;auto *layout=new QVBoxLayout(page);auto *group=new QGroupBox(section=="battle"?"技能规则":section=="bag"?"拾取 / 背包":"补给 / 恢复");auto *form=new QFormLayout(group);
    auto data=profile_.value(section).toObject();
    auto set=[this,section](QString key,QJsonValue value){if(tearingDown_)return;auto p=profile_.value(section).toObject();p.insert(key,value);if(section=="bag"){p.insert("destroy_enabled",false);p.insert("preview_valid",false);}profile_.insert(section,p);};
    auto text=[&](QString key,QString label){auto *w=new QLineEdit(data.value(key).toString());w->setMaxLength(512);form->addRow(label,w);connect(w,&QLineEdit::textChanged,page,[set,key](const QString &v){set(key,v);});};
    auto number=[&](QString key,QString label,int def,int max){auto *w=new QSpinBox;w->setRange(0,max);w->setValue(data.value(key).toInt(def));form->addRow(label,w);connect(w,&QSpinBox::valueChanged,page,[set,key](int v){set(key,v);});};
    auto checkbox=[&](QString key,QString label){auto *w=new QCheckBox(label);w->setChecked(data.value(key).toBool());form->addRow(w);connect(w,&QCheckBox::toggled,page,[set,key](bool v){set(key,v);});};
    if(section=="battle"){number("heal_percent","恢复血量 %",60,100);text("skills","技能优先级（待适配）");text("target","目标规则");checkbox("pet","启用珍兽策略");}
    if(section=="bag"){checkbox("pickup","启用拾取包裹");text("allowlist","拾取白名单");text("keep","保留 / 保护名单");text("destroy_allowlist","销毁白名单");auto *destroy=new QCheckBox("启用销毁");destroy->setEnabled(false);form->addRow(destroy);auto *preview=new QPushButton("预览销毁匹配");form->addRow(preview);connect(preview,&QPushButton::clicked,page,[this]{status_->setText("背包读取尚未接入，无法生成真实预览；销毁保持关闭");});}
    if(section=="supply"){checkbox("enabled","启用补给维护");number("empty_slots","最少背包空位",5,100);number("budget","购买 / 修理预算",0,1000000);text("medicine","药品规则");text("recovery","死亡 / 卡路 / 掉线策略");}
    layout->addWidget(group);layout->addStretch();return page;
}
void SessionPanel::refreshLegacyQueue(){if(!queue_)return;queue_->blockSignals(true);auto q=profile_.value("queue").toArray();queue_->setRowCount(q.size());for(int i=0;i<q.size();++i){auto n=q[i].toObject(),p=n.value("params").toObject();auto *check=new QTableWidgetItem;check->setCheckState(n.value("enabled").toBool(true)?Qt::Checked:Qt::Unchecked);queue_->setItem(i,0,check);queue_->setItem(i,1,new QTableWidgetItem(taskName(catalog_,n.value("task").toString())));queue_->setItem(i,2,new QTableWidgetItem(QString("%1,%2 · %3 次 · %4").arg(p.value("x").toDouble()).arg(p.value("y").toDouble()).arg(p.value("rounds").toInt(1)).arg(p.value("mode").toString())));}queue_->blockSignals(false);}
QJsonArray SessionPanel::enabledQueue() const {QJsonArray out;for(const auto &n:profile_.value("queue").toArray())if(n.toObject().value("enabled").toBool(true))out.append(n);return out;}
void SessionPanel::buildLegacy(){
    auto *outer=new QVBoxLayout(this);outer->setContentsMargins(0,0,0,0);outer->setSpacing(3);tabs_=new QTabWidget;outer->addWidget(tabs_,1);
    for(auto pair:{qMakePair(QString("副本"),QString("副本")),qMakePair(QString("日常"),QString("日常")),qMakePair(QString("活动"),QString("限时")),qMakePair(QString("生活"),QString("生活")),qMakePair(QString("挂机"),QString("野外"))})tabs_->addTab(taskPage(pair.second),pair.first);
    tabs_->addTab(rulePage("battle"),"技能");tabs_->addTab(rulePage("bag"),"拾取背包");tabs_->addTab(rulePage("supply"),"补给恢复");
    auto *flow=new QWidget;auto *fl=new QVBoxLayout(flow);queue_=new QTableWidget(0,3);queue_->setHorizontalHeaderLabels({"启用","任务","参数"});queue_->horizontalHeader()->setSectionResizeMode(0,QHeaderView::ResizeToContents);queue_->horizontalHeader()->setSectionResizeMode(1,QHeaderView::ResizeToContents);queue_->horizontalHeader()->setSectionResizeMode(2,QHeaderView::Stretch);queue_->setSelectionBehavior(QAbstractItemView::SelectRows);queue_->setEditTriggers(QAbstractItemView::NoEditTriggers);fl->addWidget(queue_);
    auto *qb=new QHBoxLayout;for(const auto &action:QStringList{"上移","下移","删除","参数"}){auto *b=new QPushButton(action);qb->addWidget(b);connect(b,&QPushButton::clicked,this,[this,action]{int i=queue_->currentRow();auto q=profile_.value("queue").toArray();if(i<0||i>=q.size())return;if(action=="删除")q.removeAt(i);if(action=="上移"&&i>0){auto n=q.takeAt(i);q.insert(i-1,n);--i;}if(action=="下移"&&i+1<q.size()){auto n=q.takeAt(i);q.insert(i+1,n);++i;}if(action=="参数"){auto n=q[i].toObject();QString node=n.value("node_id").toString();QDialog dialog(this);dialog.setWindowTitle("任务参数");auto *l=new QVBoxLayout(&dialog);l->addWidget(editor(n.value("task").toString(),n.value("params").toObject(),[this,node](QJsonObject p){auto queue=profile_.value("queue").toArray();for(int j=0;j<queue.size();++j){auto n=queue[j].toObject();if(n.value("node_id").toString()==node){n.insert("params",p);queue[j]=n;}}profile_.insert("queue",queue);}));auto *done=new QDialogButtonBox(QDialogButtonBox::Ok);l->addWidget(done);connect(done,&QDialogButtonBox::accepted,&dialog,&QDialog::accept);dialog.exec();refreshQueue();return;}profile_.insert("queue",q);refreshQueue();if(queue_->rowCount())queue_->selectRow(qBound(0,i,queue_->rowCount()-1));});}qb->addStretch();fl->addLayout(qb);tabs_->addTab(flow,"任务流程");connect(queue_,&QTableWidget::itemChanged,this,[this](QTableWidgetItem *item){if(item->column()!=0)return;auto q=profile_.value("queue").toArray();auto n=q[item->row()].toObject();n.insert("enabled",item->checkState()==Qt::Checked);q[item->row()]=n;profile_.insert("queue",q);});
    auto *settings=new QWidget;auto *sl=new QVBoxLayout(settings);auto *tools=taskPage("工具");sl->addWidget(tools,1);auto *sb=new QHBoxLayout;
    for(const auto &action:QStringList{"重新加载 Lua","关联账号 / 角色","解绑此游戏","日志"}){auto *b=new QPushButton(action);sb->addWidget(b);connect(b,&QPushButton::clicked,this,[this,action]{if(action=="重新加载 Lua"&&reloadRequested)reloadRequested();if(action=="关联账号 / 角色"&&associateRequested)associateRequested();if(action=="解绑此游戏"&&detachRequested)detachRequested();if(action=="日志")logs_->setVisible(!logs_->isVisible());});}sl->addLayout(sb);tabs_->addTab(settings,"设置");
    auto *buttons=new QHBoxLayout;buttons->setContentsMargins(8,2,8,2);start_=new QPushButton("开始流程");pause_=new QPushButton("暂停 / 恢复");stop_=new QPushButton("停止");buttons->addWidget(start_);buttons->addWidget(pause_);buttons->addWidget(stop_);buttons->addStretch();auto *copy=new QPushButton("复制配置"),*save=new QPushButton("保存");buttons->addWidget(copy);buttons->addWidget(save);outer->addLayout(buttons);connect(start_,&QPushButton::clicked,this,[this]{if(runRequested)runRequested(enabledQueue());});connect(pause_,&QPushButton::clicked,this,[this]{if(pauseRequested)pauseRequested();});connect(stop_,&QPushButton::clicked,this,[this]{if(stopRequested)stopRequested();});connect(save,&QPushButton::clicked,this,[this]{if(saveRequested)saveRequested();});connect(copy,&QPushButton::clicked,this,[this]{if(copyRequested)copyRequested();});
    logs_=new QPlainTextEdit;logs_->setReadOnly(true);logs_->setMaximumBlockCount(1000);logs_->setMaximumHeight(150);logs_->hide();outer->addWidget(logs_);status_=new QLabel;status_->setContentsMargins(8,3,8,4);status_->setWordWrap(true);outer->addWidget(status_);
    refreshQueue();tabs_->setCurrentIndex(qBound(0,profile_.value("tab").toInt(3),tabs_->count()-1));connect(tabs_,&QTabWidget::currentChanged,this,[this](int i){if(!tearingDown_)profile_.insert("tab",i);});runtime("等待绑定",false,false,{},0);
}
void SessionPanel::setProfile(QJsonObject p){const auto status=lastRuntimeStatus_;const auto live=lastLive_;const bool ready=lastReady_,busy=lastBusy_;const auto bytes=lastBytes_;tearingDown_=true;auto *old=layout();std::function<void(QLayout*)> clear=[&](QLayout *l){while(auto *item=l->takeAt(0)){if(item->widget())delete item->widget();else if(item->layout())clear(item->layout());delete item;}};clear(old);delete old;profile_=migrateTaskProfile(p);normalizeOriginalTasks();tearingDown_=false;build();runtime(status,ready,busy,live,bytes);}
void SessionPanel::runtime(QString text,bool ready,bool running,QJsonObject live,qint64 bytes){lastRuntimeStatus_=text;lastReady_=ready;lastBusy_=running;lastLive_=live;lastBytes_=bytes;refreshBattle();start_->setEnabled(ready&&!running);pause_->setEnabled(ready&&running);stop_->setEnabled(ready);QString identity=profile_.value("nickname").toString(QString("PID %1").arg(game.pid));if(live.value("position_valid").toBool())text+=QString(" · %1 %2,%3").arg(live.value("map").toString()).arg(live.value("x").toDouble(),0,'f',1).arg(live.value("y").toDouble(),0,'f',1);status_->setText(identity+" · "+text+QString(" · Worker %1 MiB").arg(bytes/1048576.0,0,'f',1));}
void SessionPanel::appendLog(const QString &line){logs_->appendPlainText(line);}
void SessionPanel::showForGame(){if(!IsWindow(reinterpret_cast<HWND>(game.window)))return;if(shown)shown();showNormal();raise();activateWindow();}
void SessionPanel::retire(){tearingDown_=true;runRequested={};flowRequested={};pauseRequested={};stopRequested={};reloadRequested={};detachRequested={};saveRequested={};copyRequested={};associateRequested={};favoritesChanged={};hide();}
void SessionPanel::closeEvent(QCloseEvent *e){if(!tearingDown_&&saveRequested)saveRequested();hide();e->ignore();}
QJsonObject SessionPanel::diagnostics()const{return {{"pid",int(game.pid)},{"panel_hwnd",QString::number(quintptr(winId()))},{"owner_hwnd",QString::number(game.window)},{"tab_count",tabs_->count()},{"visible",isVisible()},{"profile",profile_}};}
bool SessionPanel::screenshot(const QString &path){QImage image(size()*devicePixelRatioF(),QImage::Format_ARGB32);image.setDevicePixelRatio(devicePixelRatioF());render(&image);return image.save(path);}
void SessionPanel::selectTab(const QString &name){for(int i=0;i<tabs_->count();++i)if(tabs_->tabText(i)==name)tabs_->setCurrentIndex(i);}
} // namespace tlbb
