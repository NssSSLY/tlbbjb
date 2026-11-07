#include "session_panel.hpp"
#include <QComboBox>
#include <QCheckBox>
#include <QHeaderView>
#include <QJsonArray>
#include <QLabel>
#include <QPlainTextEdit>
#include <QPushButton>
#include <QTableWidget>
#include <QVBoxLayout>

namespace tlbb {
void SessionPanel::setBattleConfiguration(const QJsonObject &battle){
    const auto previous=profile_.value("battle").toObject();auto next=battle;
    if(next.value("emei_enabled").toBool()&&!previous.value("emei_enabled").toBool())next.insert("enabled",true);
    else if(!next.value("enabled").toBool(true)&&previous.value("enabled").toBool(true))next.insert("emei_enabled",false);
    profile_.insert("battle",next);
    auto system=next;system.insert("enabled",next.value("enabled").toBool(true));
    // Edit draft nodes only. FlowRunner keeps the already-running plan immutable.
    for(const auto &key:{"queue","scheduled"}){
        auto nodes=profile_.value(key).toArray();
        for(int i=0;i<nodes.size();++i){auto node=nodes[i].toObject();auto p=node.value("params").toObject();
            if(p.value("combat").toBool()||p.contains("battle_system")){p.insert("battle_system",system);node.insert("params",p);nodes[i]=node;}}
        profile_.insert(key,nodes);
    }
    for(const auto &key:QStringList{"enabled","emei_enabled"})if(auto *box=findChild<QCheckBox*>("battle_"+key)){
        const bool value=next.value(key).toBool(key=="enabled");if(box->isChecked()!=value)box->setChecked(value);
    }
}
QWidget *SessionPanel::battlePage(){
    battleView_={};auto *page=new QWidget;auto *layout=new QVBoxLayout(page);
    auto *bar=new QHBoxLayout;battleRead_=new QPushButton("读取本角色技能");battleRead_->setObjectName("battle_read");
    bar->addWidget(battleRead_);bar->addStretch();layout->addLayout(bar);
    battleVitals_=new QLabel("人物生命 / 气量：未读取");battleVitals_->setObjectName("battle_vitals");layout->addWidget(battleVitals_);
    battlePet_=new QLabel("出战珍兽：未读取");battlePet_->setObjectName("battle_pet_state");layout->addWidget(battlePet_);
    battleSkills_=new QTableWidget(0,6);battleSkills_->setObjectName("battle_learned_skills");
    battleSkills_->setHorizontalHeaderLabels({"来源","已学技能","动作 ID","可用","冷却","限制"});
    battleSkills_->setEditTriggers(QAbstractItemView::NoEditTriggers);battleSkills_->setSelectionBehavior(QAbstractItemView::SelectRows);
    battleSkills_->setSelectionMode(QAbstractItemView::SingleSelection);battleSkills_->verticalHeader()->hide();
    battleSkills_->horizontalHeader()->setSectionResizeMode(QHeaderView::ResizeToContents);
    battleSkills_->horizontalHeader()->setSectionResizeMode(1,QHeaderView::Stretch);
    battleSkills_->horizontalHeader()->setSectionResizeMode(5,QHeaderView::Stretch);layout->addWidget(battleSkills_,1);
    auto *bottom=new QHBoxLayout;auto *usage=new QComboBox;usage->setObjectName("battle_skill_usage");
    usage->addItems({"输出技能","自身治疗","自身增益","珍兽战斗手动技能","珍兽为人物回血","珍兽为人物回气","峨嵋治疗"});
    auto *add=new QPushButton("将选中技能加入配置");add->setObjectName("battle_skill_add");bottom->addWidget(usage);bottom->addWidget(add);bottom->addStretch();layout->addLayout(bottom);
    battleSkills_->setToolTip("读数来自本角色技能动作。可用状态随目标、气量和状态变化；冷却值保留游戏原值。队友治疗使用峨嵋页配置；地点、复活和特殊技能需要专用适配。");
    connect(battleRead_,&QPushButton::clicked,page,[this]{
        QJsonObject p{{"mode","legacy"},{"legacy_id","battle_inspect"},{"engine","游戏内 Lua"},{"timeout_seconds",30}};
        if(runRequested)runRequested(QJsonArray{QJsonObject{{"task","battle_inspect"},{"enabled",true},{"params",p}}});
    });
    connect(add,&QPushButton::clicked,page,[this,usage]{
        const auto row=battleSkills_->currentRow();if(row<0)return;
        const auto a=battleSkills_->item(row,1)->data(Qt::UserRole).toJsonObject();const auto index=usage->currentIndex();
        if(a.value("reason").isString()&&!a.value("reason").toString().isEmpty()){battlePet_->setText(a.value("reason").toString());return;}
        if((a.value("pet").toInt(-1)>=0)!=(index>=3&&index<=5)){battlePet_->setText("请选择与人物 / 珍兽来源一致的配置项");return;}
        const QString keys[]={"skills","heal_skills","buff_skills","pet_skills","pet_hp_skills","pet_mp_skills","emei_heal_skills"};
        auto b=profile_.value("battle").toObject();QStringList list=b.value(keys[index]).toString().replace(',', '\n').split('\n',Qt::SkipEmptyParts);
        const auto name=a.value("name").toString();if(!list.contains(name))list.append(name);
        b.insert(keys[index],list.join('\n'));setBattleConfiguration(b);
        if(auto *edit=findChild<QPlainTextEdit*>("battle_"+keys[index]))edit->setPlainText(list.join('\n'));
    });
    return page;
}
void SessionPanel::refreshBattle(){
    if(!battleSkills_||!battleVitals_)return;
    if(battleRead_)battleRead_->setEnabled(lastReady_&&!lastBusy_);
    const auto b=lastLive_.value("battle").toObject();if(b.isEmpty()||b==battleView_)return;battleView_=b;
    auto percent=[](double n,double max){return max>0?QString::number(n*100/max,'f',1)+"%":QString("—");};
    battleVitals_->setText(QString("%9（门派 ID %1） · 生命 %2 / %3（%4） · 气量 %5 / %6（%7） · 怒气 / 门派能量 %8")
        .arg(b.value("school_id").toInt()).arg(b.value("hp").toDouble()).arg(b.value("maxhp").toDouble())
        .arg(percent(b.value("hp").toDouble(),b.value("maxhp").toDouble())).arg(b.value("mp").toDouble()).arg(b.value("maxmp").toDouble())
        .arg(percent(b.value("mp").toDouble(),b.value("maxmp").toDouble())).arg(b.contains("rage")?QString::number(b.value("rage").toDouble()):QString("—")).arg(b.value("school_name").toString("未识别门派")));
    if(b.value("emei").isObject())battleVitals_->setText(battleVitals_->text()+(b.value("emei").toObject().value("attack").toBool()?" · 治疗优先 / 可输出":" · 只治疗"));
    const auto pet=b.value("pet").toObject();battlePet_->setText(pet.isEmpty()?"无出战珍兽":QString("%1 · 生命 %2 / %3（%4） · 快乐度 %5%6")
        .arg(pet.value("name").toString()).arg(pet.value("hp").toDouble()).arg(pet.value("maxhp").toDouble())
        .arg(percent(pet.value("hp").toDouble(),pet.value("maxhp").toDouble())).arg(pet.value("happy").toInt())
        .arg(b.value("pending").toString().isEmpty()?"":" · 等待反馈："+b.value("pending").toString()));
    auto skills=b.value("skills").toArray();for(const auto &a:pet.value("skills").toArray())skills.append(a);
    const auto selected=battleSkills_->currentRow();battleSkills_->setRowCount(qMin(263,int(skills.size())));
    for(int row=0;row<battleSkills_->rowCount();++row){const auto a=skills[row].toObject();
        const QStringList cells{a.value("pet").toInt(-1)<0?"人物":"珍兽",a.value("name").toString(),QString::number(a.value("id").toInt()),
            !a.value("reason").toString().isEmpty()?"待适配":!a.value("enabled").toBool()?"当前不可用":a.value("cooldown").toDouble()>0?"冷却中":"可用",
            QString::number(a.value("cooldown").toDouble()),a.value("reason").toString()};
        for(int col=0;col<cells.size();++col)battleSkills_->setItem(row,col,new QTableWidgetItem(cells[col]));
        battleSkills_->item(row,1)->setData(Qt::UserRole,a);
    }
    if(selected>=0&&selected<battleSkills_->rowCount())battleSkills_->selectRow(selected);
}
}
