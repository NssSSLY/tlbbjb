#include "session_panel.hpp"
#include "client_store.hpp"
#include "profile_config.hpp"
#include "feature_plan.hpp"
#include <QAction>
#include <QApplication>
#include <QCheckBox>
#include <QComboBox>
#include <QDialog>
#include <QDialogButtonBox>
#include <QDir>
#include <QFileDialog>
#include <QFormLayout>
#include <QGridLayout>
#include <QGroupBox>
#include <QHeaderView>
#include <QLabel>
#include <QLineEdit>
#include <QListWidget>
#include <QMenu>
#include <QPlainTextEdit>
#include <QPointer>
#include <QPushButton>
#include <QScrollArea>
#include <QSignalBlocker>
#include <QSpinBox>
#include <QSplitter>
#include <QTableWidget>
#include "original_library.hpp"
#include <QTabWidget>
#include <QTimeEdit>
#include <QTimer>
#include <QUuid>
#include <QVBoxLayout>

namespace tlbb {
static QString nameOf(const QJsonArray &catalog,const QString &id) {
    for(const auto &v:catalog)if(v.toObject().value("id").toString()==id)return v.toObject().value("name").toString();
    if(id=="luoyang_move")return "洛阳坐标移动（已移除，请删除）";
    return id;
}
static QString timeText(int minute){return QTime(minute/60,minute%60).toString("HH:mm");}
static QJsonObject field(QString key,QString label,QString kind="text",QJsonValue value={},QStringList choices={}) {
    return {{"key",key},{"label",label},{"kind",kind},{"default",value},{"choices",QJsonArray::fromStringList(choices)}};
}
void SessionPanel::selectTask(const QString &id) {
    if(!taskSelector_)return;
    for(int i=0;i<taskSelector_->count();++i)if(taskSelector_->item(i)->data(Qt::UserRole).toString()==id){
        selectTab("参数");if(taskSelector_->currentRow()==i)updateParameter();else taskSelector_->setCurrentRow(i);return;
    }
}
void SessionPanel::updateParameter() {
    if(tearingDown_||!taskSelector_||!parameterLayout_||!taskSelector_->currentItem())return;
    while(auto *item=parameterLayout_->takeAt(0)){if(item->widget())item->widget()->deleteLater();delete item;}
    const QString id=taskSelector_->currentItem()->data(Qt::UserRole).toString();profile_.insert("parameter_task",id);
    parameterLayout_->addWidget(editor(id,parameters(id),[this,id](QJsonObject p){auto tasks=profile_.value("tasks").toObject();tasks.insert(id,p);profile_.insert("tasks",tasks);}),1);
    auto *buttons=new QWidget;auto *row=new QHBoxLayout(buttons);row->setContentsMargins(0,0,0,0);
    for(const auto &action:QStringList{"加入顺序列表","加入定时列表","运行本项"}) {
        auto *button=new QPushButton(action);row->addWidget(button);
        if(action=="运行本项")button->setObjectName("taskRun_"+id);
        if(action=="运行本项"&&plannedTask(catalog_,id).value("planning_only").toBool()){
            button->setEnabled(false);button->setToolTip("任务尚未适配："+plannedTaskReason(plannedTask(catalog_,id)));
        }
        connect(button,&QPushButton::clicked,buttons,[this,id,action]{
            if(action=="运行本项"){if(runRequested)runRequested(QJsonArray{QJsonObject{{"task",id},{"enabled",true},{"params",parameters(id)}}});}
            else addTask(id,action=="加入定时列表");
        });
    }
    row->addStretch();parameterLayout_->addWidget(buttons);
}
QWidget *SessionPanel::parameterPage() {
    auto *page=new QWidget;auto *layout=new QHBoxLayout(page);layout->setContentsMargins(6,6,6,6);
    taskSelector_=new QListWidget;taskSelector_->setObjectName("parameterTasks");taskSelector_->setMaximumWidth(190);taskSelector_->setMinimumWidth(150);layout->addWidget(taskSelector_);
    for(const auto &v:catalog_){const auto t=v.toObject();auto *item=new QListWidgetItem(t.value("category").toString()+" · "+t.value("name").toString(),taskSelector_);item->setData(Qt::UserRole,t.value("id"));}
    auto *right=new QWidget;parameterLayout_=new QVBoxLayout(right);parameterLayout_->setContentsMargins(0,0,0,0);layout->addWidget(right,1);
    connect(taskSelector_,&QListWidget::currentRowChanged,page,[this]{updateParameter();});
    int selected=0;const auto id=profile_.value("parameter_task").toString("plant");for(int i=0;i<taskSelector_->count();++i)if(taskSelector_->item(i)->data(Qt::UserRole).toString()==id)selected=i;
    taskSelector_->setCurrentRow(selected);return page;
}
void SessionPanel::updateLibrary() {
    if(!library_||tearingDown_)return;
    const QSignalBlocker blocked(library_);library_->setRowCount(0);
    const QString category=category_->currentText(),search=search_->text().trimmed();const auto favorites=profile_.value("favorites").toArray();
    for(const auto &v:catalog_){const auto t=v.toObject();const QString id=t.value("id").toString();
        if(category=="优先接入"&&!t.value("plan_priority").toString().startsWith("P0"))continue;
        if(category=="常用"&&!favorites.contains(id))continue;
        if(category!="全部"&&category!="常用"&&category!="优先接入"&&t.value("category").toString()!=category)continue;
        QString haystack=t.value("name").toString()+id;for(const auto &alias:t.value("aliases").toArray())haystack+=alias.toString();
        if(!haystack.contains(search,Qt::CaseInsensitive))continue;
        const int row=library_->rowCount();library_->insertRow(row);
        auto *type=new QTableWidgetItem(t.value("category").toString());type->setData(Qt::UserRole,id);library_->setItem(row,0,type);
        library_->setItem(row,1,new QTableWidgetItem((favorites.contains(id)?"★ ":"")+t.value("name").toString()));
        auto *status=new QTableWidgetItem(taskAdapterLabel(t));status->setToolTip(plannedTaskReason(t));library_->setItem(row,2,status);
    }
}
void SessionPanel::refreshFavorites() {
    if(!favorites_||tearingDown_)return;
    const QSignalBlocker blocked(favorites_);const auto selected=favorites_->currentItem()?favorites_->currentItem()->data(Qt::UserRole).toString():QString();
    favorites_->clear();const auto list=profile_.value("favorites").toArray();
    for(int i=0;i<list.size()&&i<5;++i){const auto id=list[i].toString();if(id.isEmpty())continue;
        auto *item=new QListWidgetItem(nameOf(catalog_,id),favorites_);item->setData(Qt::UserRole,id);
        item->setToolTip(plannedTaskReason(plannedTask(catalog_,id)));if(id==selected)favorites_->setCurrentItem(item);
    }
}
void SessionPanel::setFavorite(const QString &id,bool enabled) {
    if(id.isEmpty())return;
    auto list=profile_.value("favorites").toArray();
    if(enabled){if(list.contains(id))return;if(list.size()>=5){status_->setText("常用列表最多 5 项，请先移除一项");return;}list.append(id);}
    else for(int i=list.size()-1;i>=0;--i)if(list[i].toString()==id)list.removeAt(i);
    profile_.insert("favorites",list);updateLibrary();refreshFavorites();
    if(favoritesChanged)favoritesChanged();
    status_->setText(enabled?"已加入常用":"已移出常用");
}
QWidget *SessionPanel::queueBox(bool timed) {
    auto *box=new QGroupBox(timed?"定时执行列表 [2]":"顺序执行列表 [1]");auto *layout=new QVBoxLayout(box);layout->setContentsMargins(5,8,5,5);
    if(timed){auto *timeRow=new QHBoxLayout;startTime_=new QTimeEdit;endTime_=new QTimeEdit;startTime_->setObjectName("scheduleStart");endTime_->setObjectName("scheduleEnd");
        startTime_->setDisplayFormat("HH:mm");endTime_->setDisplayFormat("HH:mm");startTime_->setTime(QTime(0,1));endTime_->setTime(QTime(23,59));timeRow->addWidget(new QLabel("时段"));timeRow->addWidget(startTime_);timeRow->addWidget(new QLabel("—"));timeRow->addWidget(endTime_);auto *edit=new QPushButton("修改选中");timeRow->addWidget(edit);layout->addLayout(timeRow);
        connect(edit,&QPushButton::clicked,box,[this]{int i=scheduled_->currentRow();auto list=profile_.value("scheduled").toArray();if(i<0||i>=list.size())return;const int a=startTime_->time().hour()*60+startTime_->time().minute(),b=endTime_->time().hour()*60+endTime_->time().minute();if(a==b){status_->setText("开始和结束时间不能相同");return;}auto n=list[i].toObject();n.insert("start_minute",a);n.insert("end_minute",b);list[i]=n;profile_.insert("scheduled",list);refreshQueue();scheduled_->selectRow(i);});
    }
    auto *table=new QTableWidget(0,timed?4:3);table->setObjectName(timed?"scheduledQueue":"regularQueue");
    if(timed)scheduled_=table;else queue_=table;
    table->setHorizontalHeaderLabels(timed?QStringList{"启用","时段","任务","状态"}:QStringList{"启用","任务","状态"});table->verticalHeader()->hide();table->setSelectionBehavior(QAbstractItemView::SelectRows);table->setSelectionMode(QAbstractItemView::SingleSelection);table->setEditTriggers(QAbstractItemView::NoEditTriggers);
    table->horizontalHeader()->setSectionResizeMode(QHeaderView::ResizeToContents);table->horizontalHeader()->setSectionResizeMode(timed?2:1,QHeaderView::Stretch);layout->addWidget(table,1);
    auto *buttons=new QHBoxLayout;for(const auto &action:QStringList{"↑","↓","删除","清空","参数"}){auto *b=new QPushButton(action);b->setObjectName((timed?"scheduled_":"regular_")+action);buttons->addWidget(b);connect(b,&QPushButton::clicked,box,[this,timed,action]{changeNode(timed,action);});}layout->addLayout(buttons);
    connect(table,&QTableWidget::itemChanged,box,[this,timed](QTableWidgetItem *item){if(tearingDown_||item->column()!=0)return;const QString key=timed?"scheduled":"queue";auto list=profile_.value(key).toArray();if(item->row()>=list.size())return;auto n=list[item->row()].toObject();n.insert("enabled",item->checkState()==Qt::Checked);list[item->row()]=n;profile_.insert(key,list);});
    connect(table,&QTableWidget::cellDoubleClicked,box,[this,timed]{editNode(timed);});
    const auto data=profile_.value("flow").toObject();
    auto option=[&](QString key,QString text,bool fallback){auto *check=new QCheckBox(text);check->setObjectName("flow_"+key);check->setChecked(data.value(key).toBool(fallback));layout->addWidget(check);connect(check,&QCheckBox::toggled,box,[this,key](bool on){if(tearingDown_)return;auto flow=profile_.value("flow").toObject();flow.insert(key,on);profile_.insert("flow",flow);});};
    if(timed){option("monitor_scheduled","启动后监视定时任务",true);option("daily_scheduled","每日重复（跨日时段归前一天）",true);option("delete_completed","成功后删除本项",false);auto *wait=new QCheckBox("当前任务完成后再执行定时任务");wait->setChecked(true);wait->setEnabled(false);layout->addWidget(wait);}
    else {option("loop","循环顺序任务",false);auto *row=new QHBoxLayout;row->addWidget(new QLabel("循环轮数（0 不限）"));auto *limit=new QSpinBox;limit->setObjectName("flow_loop_limit");limit->setRange(0,999);limit->setValue(data.value("loop_limit").toInt(1));row->addWidget(limit);layout->addLayout(row);connect(limit,&QSpinBox::valueChanged,box,[this](int v){auto flow=profile_.value("flow").toObject();flow.insert("loop_limit",v);profile_.insert("flow",flow);});}
    return box;
}
QWidget *SessionPanel::libraryPage() {
    auto *page=new QWidget;auto *layout=new QVBoxLayout(page);layout->setContentsMargins(6,6,6,6);auto *split=new QSplitter;layout->addWidget(split,1);
    auto *left=new QGroupBox("功能目录");auto *ll=new QVBoxLayout(left);auto *filters=new QHBoxLayout;
    search_=new QLineEdit;search_->setObjectName("taskSearch");search_->setPlaceholderText("搜索任务");category_=new QComboBox(page);category_->setObjectName("taskCategory");category_->addItems({"全部","副本","生活","日常","活动","限时","野外","战斗","挂机","成长","工具","交易","常用","优先接入"});for(const auto &v:catalog_){const auto c=v.toObject().value("category").toString();if(!c.isEmpty()&&category_->findText(c)<0)category_->addItem(c);}category_->hide();filters->addWidget(search_,1);ll->addLayout(filters);
    auto *catalogBody=new QHBoxLayout;categories_=new QListWidget;categories_->setObjectName("taskCategoryList");categories_->setFixedWidth(82);for(int i=0;i<category_->count();++i)categories_->addItem(category_->itemText(i));categories_->setCurrentRow(0);catalogBody->addWidget(categories_);
    library_=new QTableWidget(0,3);library_->setObjectName("taskLibrary");library_->setHorizontalHeaderLabels({"类型","功能名称","状态"});library_->verticalHeader()->hide();library_->setSelectionBehavior(QAbstractItemView::SelectRows);library_->setSelectionMode(QAbstractItemView::SingleSelection);library_->setEditTriggers(QAbstractItemView::NoEditTriggers);library_->horizontalHeader()->setSectionResizeMode(0,QHeaderView::ResizeToContents);library_->horizontalHeader()->setSectionResizeMode(1,QHeaderView::Stretch);library_->horizontalHeader()->setSectionResizeMode(2,QHeaderView::ResizeToContents);catalogBody->addWidget(library_,1);ll->addLayout(catalogBody,1);
    addScheduled_=new QCheckBox("双击添加到定时列表");ll->addWidget(addScheduled_);auto *actionRow=new QHBoxLayout;
    for(const auto &text:QStringList{"参数","加入顺序","加入定时","加入常用"}){auto *b=new QPushButton(text);if(text=="加入常用")b->setObjectName("favoriteAdd");actionRow->addWidget(b);connect(b,&QPushButton::clicked,left,[this,text]{int r=library_->currentRow();if(r<0)return;const auto id=library_->item(r,0)->data(Qt::UserRole).toString();if(text=="参数")selectTask(id);else if(text=="加入常用")setFavorite(id,true);else addTask(id,text=="加入定时");});}ll->addLayout(actionRow);split->addWidget(left);split->addWidget(queueBox(false));split->addWidget(queueBox(true));
    auto *favoriteBox=new QGroupBox("常用（最多 5 项）");favoriteBox->setMinimumWidth(140);auto *fl=new QVBoxLayout(favoriteBox);favorites_=new QListWidget;favorites_->setObjectName("favoriteTasks");fl->addWidget(favorites_,1);
    for(const auto &action:QStringList{"运行","参数","加入顺序","移除"}){auto *button=new QPushButton(action);if(action=="运行")button->setObjectName("favoriteRun");if(action=="移除")button->setObjectName("favoriteRemove");fl->addWidget(button);connect(button,&QPushButton::clicked,favoriteBox,[this,action]{auto *item=favorites_->currentItem();if(!item)return;const auto id=item->data(Qt::UserRole).toString();if(action=="移除")setFavorite(id,false);else if(action=="参数")selectTask(id);else if(action=="加入顺序")addTask(id,false);else if(plannedTask(catalog_,id).value("planning_only").toBool())status_->setText("此任务尚未适配");else if(runRequested)runRequested(QJsonArray{QJsonObject{{"task",id},{"enabled",true},{"params",parameters(id)}}});});}
    connect(favorites_,&QListWidget::itemDoubleClicked,favoriteBox,[this](QListWidgetItem *item){const auto id=item->data(Qt::UserRole).toString();if(plannedTask(catalog_,id).value("planning_only").toBool())status_->setText("此任务尚未适配");else if(runRequested)runRequested(QJsonArray{QJsonObject{{"task",id},{"enabled",true},{"params",parameters(id)}}});});
    split->addWidget(favoriteBox);split->setSizes({360,260,300,160});
    connect(search_,&QLineEdit::textChanged,page,[this]{updateLibrary();});connect(category_,&QComboBox::currentIndexChanged,page,[this](int i){if(categories_->currentRow()!=i)categories_->setCurrentRow(i);updateLibrary();});connect(categories_,&QListWidget::currentRowChanged,page,[this](int i){if(i>=0&&category_->currentIndex()!=i)category_->setCurrentIndex(i);});
    connect(library_,&QTableWidget::cellDoubleClicked,page,[this](int row){addTask(library_->item(row,0)->data(Qt::UserRole).toString(),addScheduled_->isChecked());});
    library_->setContextMenuPolicy(Qt::CustomContextMenu);connect(library_,&QTableWidget::customContextMenuRequested,page,[this](const QPoint &point){const auto *item=library_->itemAt(point);if(!item)return;const QString id=library_->item(item->row(),0)->data(Qt::UserRole).toString();QPointer<SessionPanel> self(this);QPointer<QMenu> menu=new QMenu(this);
        auto *params=menu->addAction("设置功能参数"),*run=menu->addAction("立即运行本项"),*regular=menu->addAction("加入顺序列表"),*timed=menu->addAction("加入定时列表");run->setEnabled(!plannedTask(catalog_,id).value("planning_only").toBool());const bool favorite=profile_.value("favorites").toArray().contains(id);auto *star=menu->addAction(favorite?"移出常用":"加入常用");auto *chosen=menu->exec(library_->viewport()->mapToGlobal(point));if(!self)return;if(menu)menu->deleteLater();
        if(chosen==params)selectTask(id);else if(chosen==regular)addTask(id);else if(chosen==timed)addTask(id,true);else if(chosen==run){if(runRequested)runRequested(QJsonArray{QJsonObject{{"task",id},{"enabled",true},{"params",parameters(id)}}});}else if(chosen==star)setFavorite(id,!favorite);
    });
    updateLibrary();refreshFavorites();return page;
}
void SessionPanel::addTask(const QString &id,bool timed) {
    const QString key=timed?"scheduled":"queue";auto list=profile_.value(key).toArray();if(list.size()>=64){status_->setText("每个列表最多 64 项");return;}
    QJsonObject node{{"node_id",QUuid::createUuid().toString(QUuid::WithoutBraces)},{"task",id},{"enabled",true},{"params",parameters(id)}};
    if(timed){const auto a=startTime_->time(),b=endTime_->time();if(a==b){status_->setText("开始和结束时间不能相同");return;}node.insert("start_minute",a.hour()*60+a.minute());node.insert("end_minute",b.hour()*60+b.minute());}
    list.append(node);profile_.insert(key,list);refreshQueue();status_->setText("已加入"+(timed?QString("定时"):QString("顺序"))+"列表；参数已保存为本节点快照");
}
void SessionPanel::refreshQueue() {
    for(bool timed:{false,true}){auto *table=timed?scheduled_:queue_;if(!table)continue;const QSignalBlocker blocker(table);const auto list=profile_.value(timed?"scheduled":"queue").toArray();table->setRowCount(list.size());
        for(int row=0;row<list.size();++row){const auto node=list[row].toObject();auto *enabled=new QTableWidgetItem;enabled->setCheckState(node.value("enabled").toBool(true)?Qt::Checked:Qt::Unchecked);table->setItem(row,0,enabled);int col=1;
            if(timed)table->setItem(row,col++,new QTableWidgetItem(timeText(node.value("start_minute").toInt())+"–"+timeText(node.value("end_minute").toInt())));
            auto *task=new QTableWidgetItem(nameOf(catalog_,node.value("task").toString()));task->setToolTip("参数为加入列表时的独立快照；双击编辑");table->setItem(row,col++,task);table->setItem(row,col,new QTableWidgetItem(runtimeStates_.value(node.value("node_id").toString()).toString(node.value("enabled").toBool()?"待启动":"禁用")));
        }
    }
}
void SessionPanel::flowStates(const QJsonObject &states) {
    if(states==runtimeStates_)return;
    runtimeStates_=states;refreshQueue();
}
void SessionPanel::changeNode(bool timed,const QString &action) {
    if(action=="参数"){editNode(timed);return;}auto *table=timed?scheduled_:queue_;const QString key=timed?"scheduled":"queue";auto list=profile_.value(key).toArray();int row=table->currentRow();
    if(action=="清空")list={};else{if(row<0||row>=list.size())return;if(action=="删除")list.removeAt(row);else if(action=="↑"&&row>0){auto n=list.takeAt(row);list.insert(--row,n);}else if(action=="↓"&&row+1<list.size()){auto n=list.takeAt(row);list.insert(++row,n);}}
    profile_.insert(key,list);refreshQueue();if(!list.isEmpty())table->selectRow(qBound(0,row,int(list.size()-1)));
}
void SessionPanel::editNode(bool timed) {
    auto *table=timed?scheduled_:queue_;const QString key=timed?"scheduled":"queue";const int row=table->currentRow();const auto list=profile_.value(key).toArray();if(row<0||row>=list.size())return;
    const auto node=list[row].toObject();const auto id=node.value("node_id").toString();auto *dialog=new QDialog(this);dialog->setAttribute(Qt::WA_DeleteOnClose);dialog->setWindowTitle("节点参数 · "+nameOf(catalog_,node.value("task").toString()));dialog->resize(800,560);auto *layout=new QVBoxLayout(dialog);
    layout->addWidget(editor(node.value("task").toString(),node.value("params").toObject(),[this,key,id](QJsonObject params){if(params.value("combat").toBool()){auto system=profile_.value("battle").toObject();system.insert("enabled",system.value("enabled").toBool(true));params.insert("battle_system",system);}auto nodes=profile_.value(key).toArray();for(int i=0;i<nodes.size();++i){auto n=nodes[i].toObject();if(n.value("node_id").toString()==id){n.insert("params",params);nodes[i]=n;}}profile_.insert(key,nodes);refreshQueue();}));auto *done=new QDialogButtonBox(QDialogButtonBox::Close);done->button(QDialogButtonBox::Close)->setText("完成");layout->addWidget(done);connect(done,&QDialogButtonBox::rejected,dialog,&QDialog::close);dialog->show();
}
QWidget *SessionPanel::configForm(const QString &section,const QString &title,const QJsonArray &fields) {
    auto *scroll=new QScrollArea;scroll->setWidgetResizable(true);scroll->setFrameShape(QFrame::NoFrame);auto *page=new QWidget;auto *layout=new QVBoxLayout(page);auto *group=new QGroupBox(title);auto *grid=new QGridLayout(group);const auto data=profile_.value(section).toObject();int index=0;
    for(const auto &v:fields){const auto f=v.toObject();const QString key=f.value("key").toString(),kind=f.value("kind").toString();const auto initial=data.value(key).isUndefined()?f.value("default"):data.value(key);auto set=[this,section,key](QJsonValue value){if(tearingDown_)return;auto obj=profile_.value(section).toObject();obj.insert(key,value);if(section=="bag"){obj.insert("destroy_enabled",false);obj.insert("preview_valid",false);}if(section=="battle")setBattleConfiguration(obj);else profile_.insert(section,obj);};
        auto *box=new QWidget;auto *cell=new QVBoxLayout(box);cell->setContentsMargins(0,0,0,0);cell->setAlignment(Qt::AlignTop);
        if(kind=="bool"||kind=="disabled"){auto *w=new QCheckBox(f.value("label").toString());w->setObjectName(section+"_"+key);w->setChecked(kind=="disabled"?false:initial.toBool());w->setEnabled(kind!="disabled");cell->addWidget(w);connect(w,&QCheckBox::toggled,box,[set](bool b){set(b);});}
        else{cell->addWidget(new QLabel(f.value("label").toString()));if(kind=="number"){auto *w=new QSpinBox;w->setObjectName(section+"_"+key);w->setRange(0,key.contains("percent")?100:1000000);
                if(section=="battle"){if(key.contains("percent"))w->setRange(1,95);else if(key=="cooldown_ms")w->setRange(750,5000);else if(key=="buff_interval_seconds")w->setRange(10,600);}
                w->setValue(initial.toInt());cell->addWidget(w);connect(w,&QSpinBox::valueChanged,box,[set](int n){set(n);});}
            else if(kind=="choice"){auto *w=new QComboBox;for(const auto &option:f.value("choices").toArray())w->addItem(option.toString(),option.toString());
                const auto saved=initial.toString();int selected=w->findData(saved);if(selected<0){w->addItem(saved.isEmpty()?QString("未设置"):saved+"（已保存）",saved);selected=w->count()-1;}w->setCurrentIndex(selected);
                w->setObjectName(section+"_"+key);cell->addWidget(w);connect(w,&QComboBox::currentIndexChanged,box,[set,w](int){set(w->currentData().toString());});}
            else if(kind=="lines"){auto *w=new QPlainTextEdit(initial.toString());w->setObjectName(section+"_"+key);w->setMaximumHeight(105);w->setMaximumBlockCount(128);
                const auto hint=key=="emei_heal_skills"?QString("留空按已学技能选择清心普善咒、冲虚养气；手填时每行一个完整技能名，按顺序尝试"):QString("每行填写一项，按游戏内显示的完整名称输入");
                w->setPlaceholderText(hint);w->setToolTip(hint);cell->addWidget(w);connect(w,&QPlainTextEdit::textChanged,box,[set,w]{if(w->toPlainText().size()<=4096)set(w->toPlainText());});}
            else{auto *w=new QLineEdit(initial.toString());w->setObjectName(section+"_"+key);w->setMaxLength(512);
                const QString hint=key=="leader"?"输入队长的游戏昵称":key=="pet_name"?"输入珍兽名称；留空使用当前出战珍兽":key=="warehouse"?"输入游戏内存仓地点":"按游戏内显示的完整名称或规则填写";
                w->setPlaceholderText(hint);w->setToolTip(hint);cell->addWidget(w);connect(w,&QLineEdit::textChanged,box,[set](const QString &s){set(s);});}}
        grid->addWidget(box,index/2,index%2);++index;
    }
    grid->setColumnStretch(0,1);grid->setColumnStretch(1,1);layout->addWidget(group);layout->addStretch();scroll->setWidget(page);return scroll;
}
QWidget *SessionPanel::rulePage(const QString &section) {
    auto *tabs=new QTabWidget;
    if(section=="protection"){
        tabs->addTab(configForm("supply","恢复补给 · 待适配",{field("enabled","启用补给维护","bool",false),field("empty_slots","背包最少空位","number",5),field("budget","购买 / 修理预算","number",0),field("hp_percent","人物血量低于 %","number",60),field("mp_percent","人物气量低于 %","number",30),field("pet_percent","珍兽血量低于 %","number",50),field("medicine","药品规则","lines"),field("repair","自动修理","bool",false)}),"恢复补给");
        tabs->addTab(configForm("protection","异常处理 · 待适配",{field("death","死亡后","choice","停止任务",{"停止任务","等待人工","尝试返回"}),field("disconnect","掉线后","choice","停止任务",{"停止任务","等待人工","重新登录（待适配）"}),field("stuck_seconds","卡路判定 / 秒","number",30),field("recovery_limit","恢复尝试上限","number",2),field("red_name_stop","红名时停止","bool",true),field("manual_override","人工移动后重新核对任务状态","bool",true)}),"异常处理");
        tabs->addTab(configForm("protection","结束条件 · 待适配",{field("stop_minutes","挂机时长上限 / 分钟（0 不限）","number",0),field("stop_level","达到等级停止（0 不限）","number",0),field("bag_full","背包满时","choice","停止任务",{"停止任务","等待人工","补给维护（待适配）"}),field("after_finish","全部任务结束后","choice","原地待命",{"原地待命","等待人工"})}),"结束条件");
    }else if(section=="battle"){
        tabs->addTab(battlePage(),"状态 / 已学技能");
        auto *emei=configForm("battle","峨嵋治疗策略",{field("emei_enabled","启用峨嵋专用策略（按角色实际门派）","bool",false),field("emei_attack","参与攻击（未勾选时只治疗）","bool",false),field("emei_team_heal","治疗队友","bool",true),field("emei_heal_percent","治疗触发血量 %","number",75),field("emei_self_priority_percent","优先自保血量 %","number",35),field("emei_heal_skills","治疗技能顺序（留空自动选择已学技能）","lines")});
        tabs->addTab(emei,"峨嵋");
        auto *enableEmei=emei->findChild<QCheckBox*>("battle_emei_enabled");
        auto updateEmei=[emei,enableEmei]{for(const auto &key:QStringList{"emei_attack","emei_team_heal","emei_heal_percent","emei_self_priority_percent","emei_heal_skills"})if(auto *w=emei->findChild<QWidget*>("battle_"+key))w->setEnabled(enableEmei&&enableEmei->isChecked());};
        if(enableEmei)connect(enableEmei,&QCheckBox::toggled,emei,[updateEmei](bool){updateEmei();});
        updateEmei();
        tabs->addTab(configForm("battle","角色输出",{field("enabled","启用战斗维护（游戏内 Lua）","bool",true),field("school","门派备注","choice","自动识别",{"自动识别","少林","明教","丐帮","武当","峨嵋","星宿","天龙","天山","逍遥","慕容","唐门","鬼谷","桃花岛","绝情谷","恶人谷","昆仑"}),field("skills","输出优先级（每行一项；空为基础攻击）","lines"),field("cooldown_ms","输出间隔 / 毫秒（750–5000）","number",1000)}),"输出技能");
        tabs->addTab(configForm("battle","目标规则 · 待适配",{field("target","目标优先级（每行一项）","lines"),field("follow_leader","优先队长目标","bool",true),field("avoid_protected","排除保护目标","bool",true)}),"目标规则");
        tabs->addTab(configForm("battle","自身恢复 · 已接入，待实测",{field("heal_enabled","启用自身治疗","bool",false),field("heal_percent","人物生命低于 % 时恢复","number",60),field("heal_skills","自身治疗技能（每行一项）","lines"),field("mp_percent","人物气量低于 % 时使用珍兽回气","number",30),field("heal_only","仅自身恢复，不输出","bool",false)}),"人物恢复");
        tabs->addTab(configForm("battle","自身增益 · 已接入，待实测",{field("buff_enabled","启用自身增益","bool",false),field("buff_interval_seconds","最小重复间隔 / 秒（10–600）","number",60),field("buff_skills","自身增益技能（每行一项）","lines")}),"自身增益");
        tabs->addTab(configForm("battle","出战珍兽 · 已接入，待实测",{field("pet","启用珍兽维护","bool",false),field("pet_name","指定珍兽名称（空为当前出战珍兽）"),field("pet_feed","生命不足时使用已有口粮喂养","bool",false),field("pet_feed_percent","喂养阈值 %","number",50),field("pet_stop_percent","珍兽生命停止阈值 %","number",20),field("pet_sacrifice_min_percent","共生 / 血祭最低珍兽生命 %","number",65),field("pet_hp_skills","人物回血技能（如高级共生）","lines"),field("pet_mp_skills","人物回气技能（如高级血祭）","lines"),field("pet_skills","战斗中手动技能（每行一项）","lines")}),"珍兽策略");
    }else if(section=="team"){
        tabs->addTab(configForm("team","组队 / 组团 · 待适配",{field("role","职责","choice","独立执行",{"独立执行","队长","跟随队长","团队辅助"}),field("leader","指定队长"),field("members","队员名单（每行一项）","lines"),field("follow_distance","跟随距离","number",5),field("auto_accept","接受名单内邀请","bool",false),field("auto_follow","自动跟随","bool",false),field("wait_members","等待队员到齐","bool",true),field("timeout_seconds","组队等待 / 秒","number",120)}),"队伍设置");
    }
    return tabs;
}
QWidget *SessionPanel::itemPage() {
    auto *tabs=new QTabWidget;
    tabs->setObjectName("itemTabs");
    tabs->addTab(configForm("bag","拾取规则 · 待适配",{field("pickup","启用拾取包裹","bool",false),field("allowlist","拾取白名单（每行一项）","lines"),field("pickup_ignore","忽略名单","lines"),field("pickup_radius","拾取范围","number",10)}),"拾取");
    tabs->addTab(configForm("bag","物品保护 · 待适配",{field("keep","保留名单","lines"),field("keep_locked","保护锁定物品","bool",true),field("keep_equipped","保护已装备物品","bool",true),field("keep_quest","保护任务物品","bool",true),field("keep_unknown","保护属性未知物品","bool",true)}),"保留保护");
    tabs->addTab(configForm("bag","出售 / 存仓 · 待适配",{field("sell_allowlist","出售白名单","lines"),field("warehouse_allowlist","存仓白名单","lines"),field("sell_budget","单轮出售数量上限","number",20),field("warehouse","存仓地点")}),"出售存仓");
    tabs->addTab(configForm("bag","销毁规则 · 背包真实预览接入前不可启用",{field("destroy_enabled","启用销毁","disabled",false),field("destroy_allowlist","销毁白名单","lines"),field("destroy_limit","单轮数量上限","number",1)}),"销毁");
    auto *listing=new QWidget;auto *layout=new QVBoxLayout(listing);auto *settings=configForm("trade","自动上架规则 · 待适配",{field("from_warehouse","从仓库补充","bool",false),field("relist","重新上架售出物品","bool",false),field("failed_limit","失败上限","number",3),field("listing_place","上架位置","choice","钱庄",{"钱庄","天外"})});settings->setMaximumHeight(195);layout->addWidget(settings);
    auto *table=new QTableWidget;table->setObjectName("listingRules");table->setColumnCount(6);table->setHorizontalHeaderLabels({"启用","物品名称","定价方式","价格","上架位置","拆分"});table->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);table->setSelectionBehavior(QAbstractItemView::SelectRows);layout->addWidget(table,1);
    auto refresh=[this,table]{
        const QSignalBlocker blocker(table);const auto rows=profile_.value("trade").toObject().value("listings").toArray();table->setRowCount(rows.size());
        for(int i=0;i<rows.size();++i){const auto r=rows[i].toObject();auto *check=new QTableWidgetItem;check->setCheckState(r.value("enabled").toBool()?Qt::Checked:Qt::Unchecked);table->setItem(i,0,check);
            for(int j=1;j<6;++j){const QString key=QStringList{"","name","pricing","price","place","split"}[j];auto *item=new QTableWidgetItem(j==3?QString::number(r.value(key).toInt()):r.value(key).toString());
                if(j==1)item->setToolTip("输入游戏中物品的完整名称");
                if(j==2)item->setToolTip("定价规则尚未接入；例如：手动");
                if(j==3)item->setToolTip("输入非负整数价格");
                if(j==5)item->setToolTip("拆分规则尚未接入；例如：不拆");
                table->setItem(i,j,item);}
            auto *place=new QComboBox;place->setObjectName(QString("listing_place_%1").arg(i));place->addItem("钱庄","钱庄");place->addItem("天外","天外");
            const auto saved=r.value("place").toString();int selected=place->findData(saved);if(selected<0){place->addItem(saved.isEmpty()?QString("未设置"):saved+"（已保存）",saved);selected=place->count()-1;}place->setCurrentIndex(selected);
            table->setCellWidget(i,4,place);connect(place,&QComboBox::currentIndexChanged,place,[this,i,place](int){if(tearingDown_)return;auto trade=profile_.value("trade").toObject();auto rows=trade.value("listings").toArray();if(i>=rows.size())return;auto row=rows[i].toObject();row.insert("place",place->currentData().toString());rows[i]=row;trade.insert("listings",rows);profile_.insert("trade",trade);});
        }
    };refresh();
    connect(table,&QTableWidget::itemChanged,listing,[this,table](QTableWidgetItem *item){auto trade=profile_.value("trade").toObject();auto rows=trade.value("listings").toArray();if(item->row()>=rows.size())return;auto r=rows[item->row()].toObject();const int col=item->column();if(col==0)r.insert("enabled",item->checkState()==Qt::Checked);else{const QString key=QStringList{"","name","pricing","price","place","split"}[col];if(col==3){bool ok=false;const int price=item->text().toInt(&ok);if(!ok||price<0){status_->setText("上架价格应为非负整数");return;}r.insert(key,price);}else r.insert(key,item->text().left(128));}rows[item->row()]=r;trade.insert("listings",rows);profile_.insert("trade",trade);});
    auto *buttons=new QHBoxLayout;auto *add=new QPushButton("添加物品规则"),*remove=new QPushButton("删除选中"),*read=new QPushButton("读取背包");read->setEnabled(false);read->setToolTip("背包接口尚未接入");buttons->addWidget(add);buttons->addWidget(remove);buttons->addWidget(read);buttons->addStretch();layout->addLayout(buttons);
    connect(add,&QPushButton::clicked,listing,[this,refresh]{auto t=profile_.value("trade").toObject();auto rows=t.value("listings").toArray();if(rows.size()>=128){status_->setText("最多 128 条上架规则");return;}rows.append(QJsonObject{{"enabled",false},{"name",""},{"pricing","手动"},{"price",0},{"place","钱庄"},{"split","不拆"}});t.insert("listings",rows);profile_.insert("trade",t);refresh();});
    connect(remove,&QPushButton::clicked,listing,[this,table,refresh]{auto t=profile_.value("trade").toObject();auto rows=t.value("listings").toArray();const int i=table->currentRow();if(i>=0&&i<rows.size()){rows.removeAt(i);t.insert("listings",rows);profile_.insert("trade",t);refresh();}});tabs->addTab(listing,"自动上架");
    tabs->addTab(configForm("trade","交易 / 兑换规则 · 待适配",{field("partner","交易对象白名单"),field("items","物品与数量（每行一项）","lines"),field("budget","单轮支出上限","number",0),field("confirm","交易确认方式","choice","等待人工",{"等待人工","按规则核对（待适配）"})}),"交易兑换");return tabs;
}
QWidget *SessionPanel::savePage() {
    auto *page=new QWidget;auto *layout=new QVBoxLayout(page);auto *buttons=new QHBoxLayout;
    for(const auto &action:QStringList{"保存当前角色","导出任务配置","导入任务配置","复制到其他角色"}){auto *button=new QPushButton(action);buttons->addWidget(button);connect(button,&QPushButton::clicked,page,[this,action]{
        if(action=="保存当前角色"){if(saveRequested)saveRequested();return;}if(action=="复制到其他角色"){if(copyRequested)copyRequested();return;}
        const QString initial=QCoreApplication::applicationDirPath()+"/data/task-profile.json";QString error;
        if(action=="导出任务配置"){const auto file=QFileDialog::getSaveFileName(this,"导出任务配置",initial,"任务配置 (*.json)");if(file.isEmpty())return;if(ClientStore::writeJson(file,portableProfile(profile_),error))status_->setText("已导出任务和规则配置");else status_->setText(error);}
        else{const auto file=QFileDialog::getOpenFileName(this,"导入任务配置",QCoreApplication::applicationDirPath()+"/data","任务配置 (*.json)");if(file.isEmpty())return;QJsonObject imported;if(!readPortableProfile(ClientStore::readJson(file),imported,error)){status_->setText(error);return;}auto merged=profile_;for(auto i=imported.begin();i!=imported.end();++i)merged.insert(i.key(),i.value());QTimer::singleShot(0,this,[this,merged]{if(tearingDown_)return;setProfile(merged);status_->setText("任务配置已导入草稿，运行中的快照保持不变");});}
    });}layout->addLayout(buttons);layout->addWidget(new QLabel("配置文件只包含任务与规则；账号、密码、角色身份和运行状态不导出。"));layout->addStretch();return page;
}
void SessionPanel::build() {
    queue_=scheduled_=library_=nullptr;taskSelector_=categories_=favorites_=nullptr;parameterLayout_=nullptr;auto *outer=new QVBoxLayout(this);outer->setContentsMargins(0,0,0,0);outer->setSpacing(3);tabs_=new QTabWidget;tabs_->setObjectName("sessionTabs");outer->addWidget(tabs_,1);
    tabs_->addTab(libraryPage(),"所有功能");tabs_->addTab(parameterPage(),"参数");tabs_->addTab(rulePage("protection"),"保护");tabs_->addTab(rulePage("battle"),"技能");tabs_->addTab(rulePage("team"),"组队组团");tabs_->addTab(itemPage(),"物品");
    auto *other=new QWidget;auto *otherLayout=new QVBoxLayout(other);auto *settings=configForm("other","执行偏好",{field("allow_manual","允许人工干预后重新核对任务","bool",true),field("log_level","日志级别","choice","普通",{"普通","详细"})});otherLayout->addWidget(settings,1);auto *actions=new QHBoxLayout;
    for(const auto &text:QStringList{"重新加载 Lua","关联账号 / 角色","解绑此游戏"}){auto *b=new QPushButton(text);actions->addWidget(b);connect(b,&QPushButton::clicked,other,[this,text]{if(text=="重新加载 Lua"&&reloadRequested)reloadRequested();if(text=="关联账号 / 角色"&&associateRequested)associateRequested();if(text=="解绑此游戏"&&detachRequested)detachRequested();});}otherLayout->addLayout(actions);tabs_->addTab(other,"其他");
    auto *info=new QWidget;auto *infoLayout=new QVBoxLayout(info);infoLayout->addWidget(new QLabel(QString("当前游戏 PID：%1").arg(game.pid)));
    auto *infoTabs=new QTabWidget;infoTabs->setObjectName("sessionInfoTabs");logs_=new QPlainTextEdit;logs_->setObjectName("sessionLog");logs_->setReadOnly(true);logs_->setMaximumBlockCount(1000);infoTabs->addTab(logs_,"运行日志");
    const auto registry=ClientStore::readJson(QCoreApplication::applicationDirPath()+"/scripts/builtin/dungeons/catalog.json").value("entries").toArray();
    auto *dungeons=new QTableWidget(registry.size(),4);dungeons->setObjectName("dungeonRegistry");dungeons->setHorizontalHeaderLabels({"原副本 / 活动模块","执行方式","接入状态","直接参数项"});
    dungeons->setEditTriggers(QAbstractItemView::NoEditTriggers);dungeons->setSelectionBehavior(QAbstractItemView::SelectRows);dungeons->verticalHeader()->hide();dungeons->horizontalHeader()->setSectionResizeMode(QHeaderView::ResizeToContents);dungeons->horizontalHeader()->setSectionResizeMode(0,QHeaderView::Stretch);
    for(int row=0;row<registry.size();++row){const auto d=registry[row].toObject();const auto settings=d.value("direct_settings").toArray();QStringList keys;for(const auto &v:settings){const auto f=v.toObject();keys.append(f.value("section").toString()+"/"+f.value("key").toString());}
        const QStringList cells{d.value("name").toString(),d.value("mode").toString()=="game_ui_sweep"?"游戏内扫荡":"完整流程",d.value("runtime_enabled").toBool()?"已接入 · 待实测":"原规则已核对 · 待接入",QString::number(settings.size())};
        for(int col=0;col<4;++col){auto *item=new QTableWidgetItem(cells[col]);item->setToolTip(col==3?keys.join('\n'):d.value("source").toString());dungeons->setItem(row,col,item);}}
    infoTabs->addTab(dungeons,"副本接入清单");
    const auto plan=ClientStore::readJson(QCoreApplication::applicationDirPath()+"/scripts/builtin/planning/feature-plan.json");
    const auto features=plan.value("features").toArray();auto *roadmap=new QTableWidget(features.size(),5);roadmap->setObjectName("featurePlanRegistry");
    roadmap->setHorizontalHeaderLabels({"功能","优先级","状态","原规则数","待接能力"});roadmap->setEditTriggers(QAbstractItemView::NoEditTriggers);
    roadmap->setSelectionBehavior(QAbstractItemView::SelectRows);roadmap->setWordWrap(false);roadmap->verticalHeader()->hide();roadmap->horizontalHeader()->setSectionResizeMode(QHeaderView::ResizeToContents);
    roadmap->horizontalHeader()->setSectionResizeMode(0,QHeaderView::Stretch);roadmap->horizontalHeader()->setSectionResizeMode(4,QHeaderView::Stretch);
    for(int row=0;row<features.size();++row){const auto f=features[row].toObject();QStringList missing;for(const auto &m:f.value("blocked_by").toArray())missing<<m.toString();
        const QStringList cells{f.value("name").toString(),f.value("priority").toString(),f.value("runtime_enabled").toBool()?"已接入·待实测":"原规则已定位·待接入",QString::number(f.value("source_tokens").toArray().size()),missing.join("；")};
        for(int col=0;col<cells.size();++col){auto *item=new QTableWidgetItem(cells[col]);item->setToolTip(cells[col]);item->setData(Qt::UserRole,f.value("task_id"));roadmap->setItem(row,col,item);}}
    roadmap->resizeRowsToContents();
    connect(roadmap,&QTableWidget::cellDoubleClicked,this,[this,roadmap](int row){selectTask(roadmap->item(row,0)->data(Qt::UserRole).toString());});
    infoTabs->addTab(roadmap,"功能接入规划");
    QString originalError;const auto originalIndex=originalLibraryIndex(QCoreApplication::applicationDirPath()+"/scripts/builtin/legacy",originalError);
    auto originals=originalIndex.value("modules").toArray();for(const auto &v:originalIndex.value("custom_sources").toArray())originals.append(v);
    auto *originalPage=new QWidget;auto *originalLayout=new QVBoxLayout(originalPage);originalLayout->setContentsMargins(0,0,0,0);
    auto *originalSearch=new QLineEdit;originalSearch->setObjectName("originalRuleSearch");originalSearch->setPlaceholderText("搜索原 Lua、分类、配置键或依赖");originalLayout->addWidget(originalSearch);
    auto *originalTable=new QTableWidget(originals.size(),6);originalTable->setObjectName("originalRuleRegistry");
    originalTable->setHorizontalHeaderLabels({"分类","原 Lua","执行状态","原指令数","直接配置项","模块依赖"});
    originalTable->setEditTriggers(QAbstractItemView::NoEditTriggers);originalTable->setSelectionBehavior(QAbstractItemView::SelectRows);originalTable->setWordWrap(false);
    originalTable->verticalHeader()->hide();originalTable->horizontalHeader()->setSectionResizeMode(QHeaderView::ResizeToContents);
    originalTable->horizontalHeader()->setSectionResizeMode(1,QHeaderView::Stretch);originalTable->horizontalHeader()->setSectionResizeMode(5,QHeaderView::Stretch);
    const auto declared=ClientStore::readJson(QCoreApplication::applicationDirPath()+"/scripts/builtin/legacy/manifest.json").value("tasks").toArray();
    for(int row=0;row<originals.size();++row){const auto m=originals[row].toObject();QString status="已入库·待宿主",taskId;QStringList configKeys,dependencies;
        for(const auto &field:m.value("direct_settings").toArray()){const auto s=field.toObject();configKeys<<s.value("section").toString()+"/"+s.value("key").toString();}
        for(const auto &name:m.value("literal_modules").toArray())dependencies<<name.toString();
        for(const auto &v:catalog_){const auto task=v.toObject();if(task.value("planning_only").toBool()&&task.value("original_library_tokens").toArray().contains(m.value("token"))){
            status="原规则已定位·待接入";taskId=task.value("id").toString();break;}}
        for(const auto &v:declared){const auto d=v.toObject();if(d.value("original_chunk_sha256").toString()==m.value("original_sha256").toString()&&d.value("original_bytecode").toBool()&&d.value("runtime_enabled")!=QJsonValue(false)){
            status="原规则已接入·待实测";taskId=d.value("id").toString();break;}}
        if(m.value("known_empty_stub").toBool())status="原文件空壳·不可执行";
        if(m.value("format").toString()=="source")for(const auto &v:declared){const auto d=v.toObject();if(d.value("original_sha256").toString()==m.value("original_sha256").toString())status="已有适配入口·待实测";}
        const QStringList cells{m.value("group").toString(),m.value("name").toString(),status,m.value("format").toString()=="source"?"源码":QString::number(m.value("instructions").toInt()),QString::number(configKeys.size()),dependencies.join("、")};
        const auto searchText=cells.join(' ')+" "+configKeys.join(' ');
        for(int col=0;col<cells.size();++col){auto *item=new QTableWidgetItem(cells[col]);item->setData(Qt::UserRole,taskId);item->setData(Qt::UserRole+1,searchText);
            item->setToolTip(col==4?configKeys.join('\n')+"\n仅静态直接读取，间接 / 动态键未穷尽":m.value("source").toString());originalTable->setItem(row,col,item);}}
    originalTable->resizeRowsToContents();originalLayout->addWidget(originalTable,1);
    if(!originalError.isEmpty())originalSearch->setPlaceholderText(originalError);
    connect(originalSearch,&QLineEdit::textChanged,originalPage,[originalTable](const QString &text){for(int row=0;row<originalTable->rowCount();++row)originalTable->setRowHidden(row,!originalTable->item(row,0)->data(Qt::UserRole+1).toString().contains(text,Qt::CaseInsensitive));});
    connect(originalTable,&QTableWidget::cellDoubleClicked,this,[this,originalTable](int row){const auto id=originalTable->item(row,0)->data(Qt::UserRole).toString();if(!id.isEmpty())selectTask(id);});
    infoTabs->addTab(originalPage,"原 Lua 模块");infoLayout->addWidget(infoTabs,1);tabs_->addTab(info,"信息");tabs_->addTab(savePage(),"保存");
    auto *buttons=new QHBoxLayout;buttons->setContentsMargins(8,2,8,2);start_=new QPushButton("启动脚本");start_->setObjectName("startFlow");pause_=new QPushButton("暂停 / 恢复");stop_=new QPushButton("停止脚本");buttons->addWidget(start_);buttons->addWidget(pause_);buttons->addWidget(stop_);buttons->addStretch();auto *copy=new QPushButton("复制配置"),*save=new QPushButton("保存");buttons->addWidget(copy);buttons->addWidget(save);outer->addLayout(buttons);
    connect(start_,&QPushButton::clicked,this,[this]{if(flowRequested)flowRequested(QJsonObject{{"queue",profile_.value("queue").toArray()},{"scheduled",profile_.value("scheduled").toArray()},{"flow",profile_.value("flow").toObject()}});else if(runRequested)runRequested(enabledQueue());});connect(pause_,&QPushButton::clicked,this,[this]{if(pauseRequested)pauseRequested();});connect(stop_,&QPushButton::clicked,this,[this]{if(stopRequested)stopRequested();});connect(copy,&QPushButton::clicked,this,[this]{if(copyRequested)copyRequested();});connect(save,&QPushButton::clicked,this,[this]{if(saveRequested)saveRequested();});
    status_=new QLabel;status_->setContentsMargins(8,3,8,4);status_->setWordWrap(true);outer->addWidget(status_);refreshQueue();tabs_->setCurrentIndex(qBound(0,profile_.value("tab").toInt(),tabs_->count()-1));connect(tabs_,&QTabWidget::currentChanged,this,[this](int i){if(!tearingDown_)profile_.insert("tab",i);});runtime("等待绑定",false,false,{},0);
}
} // namespace tlbb
