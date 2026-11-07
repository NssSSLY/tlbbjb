#pragma once
#include "session_panel.hpp"
#include <QComboBox>
#include <QCheckBox>
#include <QDoubleSpinBox>
#include <QJsonDocument>
#include <QListWidget>
#include <QLineEdit>
#include <QScrollArea>
#include <QPixmap>
#include <QDir>
#include <QToolButton>
#include <QTimeEdit>
#include <QCoreApplication>
#include <QEvent>
#include <QPushButton>
#include <QTableWidget>
#include <QSpinBox>
#include <cstdio>

// Exercises the widgets without a game process, global hotkeys, or user input.
static int runCatalogUiTests() {
    auto check=[](bool ok,const char *name){if(!ok)std::fprintf(stderr,"catalog UI test failed: %s\n",name);return ok;};
    tlbb::SessionPanel panel(tlbb::GameInfo{},{});
    auto *categories=panel.findChild<QListWidget*>("taskCategoryList");
    auto *category=panel.findChild<QComboBox*>("taskCategory");
    auto *library=panel.findChild<QTableWidget*>("taskLibrary");
    auto *favorites=panel.findChild<QListWidget*>("favoriteTasks");
    auto *add=panel.findChild<QPushButton*>("favoriteAdd");
    auto *run=panel.findChild<QPushButton*>("favoriteRun");
    auto *remove=panel.findChild<QPushButton*>("favoriteRemove");
    if(!check(categories&&category&&library&&favorites&&add&&run&&remove,"controls"))return 1;
    for(const auto &name:QStringList{"全部","副本","生活","日常","活动"})
        if(!check(!categories->findItems(name,Qt::MatchExactly).isEmpty(),"category visible"))return 1;
    categories->setCurrentRow(category->findText("副本"));
    if(!check(library->rowCount()>0,"dungeon category has tasks"))return 1;
    for(int i=0;i<library->rowCount();++i)
        if(!check(library->item(i,0)->text()=="副本","category filter"))return 1;
    categories->setCurrentRow(category->findText("全部"));
    int sign=-1;
    for(int i=0;i<library->rowCount();++i)if(library->item(i,0)->data(Qt::UserRole).toString()=="daily_sign")sign=i;
    if(!check(sign>=0,"daily sign present"))return 1;
    int changes=0;panel.favoritesChanged=[&]{++changes;};
    library->selectRow(sign);add->click();
    if(!check(favorites->count()==1&&changes==1,"add favorite"))return 1;
    for(int i=0;i<library->rowCount()&&favorites->count()<5;++i){library->selectRow(i);add->click();}
    if(!check(favorites->count()==5,"five favorites"))return 1;
    for(int i=0;i<library->rowCount();++i){
        const auto id=library->item(i,0)->data(Qt::UserRole).toString();
        if(!panel.profile().value("favorites").toArray().contains(id)){library->selectRow(i);add->click();break;}
    }
    if(!check(favorites->count()==5&&changes==5,"limit five"))return 1;
    QJsonArray requested;panel.runRequested=[&](QJsonArray tasks){requested=tasks;};
    favorites->setCurrentRow(0);run->click();
    if(!check(requested.size()==1&&requested[0].toObject().value("task").toString()=="daily_sign","run selected favorite"))return 1;
    const auto saved=QJsonDocument::fromJson(QJsonDocument(panel.profile()).toJson()).object();
    tlbb::SessionPanel restored(tlbb::GameInfo{},saved),other(tlbb::GameInfo{},{});
    if(!check(restored.findChild<QListWidget*>("favoriteTasks")->count()==5,"restore favorites"))return 1;
    if(!check(other.findChild<QListWidget*>("favoriteTasks")->count()==0,"separate profiles"))return 1;
    remove->click();
    if(!check(favorites->count()==4&&changes==6,"remove favorite"))return 1;
    panel.selectTask("dungeon_00320005");
    panel.selectTask("dungeon_002fbdb4");
    auto *waterTeam=panel.findChild<QDoubleSpinBox*>("dungeon_002fbdb4_dungeon_team_count");
    auto *waterRounds=panel.findChild<QDoubleSpinBox*>("dungeon_002fbdb4_dungeon_rounds");
    if(!check(waterTeam&&waterTeam->minimum()==3&&waterTeam->maximum()==6&&waterRounds&&waterRounds->maximum()==20,"water prison full-flow settings"))return 1;
    waterRounds->setValue(2);
    if(!check(panel.profile().value("tasks").toObject().value("dungeon_002fbdb4").toObject().value("dungeon_rounds").toInt()==2,"water prison rounds saved"))return 1;
    panel.selectTask("sijue");
    auto *sijueDifficulty=panel.findChild<QComboBox*>("sijue_sjz_type");
    auto *sijueBell=panel.findChild<QComboBox*>("sijue_sijue_bell_role");
    auto *sijueColumn=panel.findChild<QCheckBox*>("sijue_sijue_columns");
    auto *sijueShare=panel.findChild<QCheckBox*>("sijue_sijue_blind_share");
    auto *sijueTrap=panel.findChild<QDoubleSpinBox*>("sijue_sijue_trap_distance");
    if(!check(sijueDifficulty&&sijueDifficulty->count()==4&&sijueDifficulty->currentText()=="普通"&&sijueBell&&sijueBell->count()==3&&sijueColumn&&sijueShare&&sijueTrap&&sijueTrap->minimum()==2&&sijueTrap->maximum()==10,"sijue implemented settings"))return 1;
    sijueDifficulty->setCurrentText("高级");sijueBell->setCurrentText("其他队友");sijueColumn->setChecked(false);sijueShare->setChecked(true);sijueTrap->setValue(6);
    const auto sijueParams=panel.profile().value("tasks").toObject().value("sijue").toObject();
    if(!check(sijueParams.value("sjz_type")==QJsonValue("高级")&&sijueParams.value("sijue_bell_role")==QJsonValue("其他队友")&&!sijueParams.value("sijue_columns").toBool()&&sijueParams.value("sijue_blind_share").toBool()&&sijueParams.value("sijue_trap_distance").toInt()==6,"sijue settings saved"))return 1;
    panel.selectTask("yanzi");
    auto *yanziMode=panel.findChild<QComboBox*>("yanzi_yzw_type");
    auto *yanziSupply=panel.findChild<QCheckBox*>("yanzi_yanzi_supplies");
    auto *yanziWyy=panel.findChild<QCheckBox*>("yanzi_yanzi_kill_wyy");
    if(!check(yanziMode&&yanziMode->count()==4&&yanziMode->currentText()=="普通"&&yanziSupply&&yanziSupply->isChecked()&&yanziWyy&&!panel.findChild<QLineEdit*>("yanzi_bjk137"),"yanzi practical settings"))return 1;
    yanziMode->setCurrentText("高级");yanziSupply->setChecked(false);yanziWyy->setChecked(true);
    const auto yanziParams=panel.profile().value("tasks").toObject().value("yanzi").toObject();
    if(!check(yanziParams.value("yzw_type")==QJsonValue("高级")&&!yanziParams.value("yanzi_supplies").toBool()&&yanziParams.value("yanzi_kill_wyy").toBool(),"yanzi settings saved"))return 1;
    panel.selectTask("dungeon_00320005");
    auto *team=panel.findChild<QDoubleSpinBox*>("dungeon_00320005_老三环");
    if(!check(team&&team->minimum()==0&&team->maximum()==6,"dungeon team setting"))return 1;
    team->setValue(4);
    if(!check(panel.profile().value("tasks").toObject().value("dungeon_00320005").toObject().value("老三环").toInt()==4,"dungeon team setting saved"))return 1;
    panel.selectTask("dungeon_new_sanhuan");
    auto *newTeam=panel.findChild<QDoubleSpinBox*>("dungeon_new_sanhuan_dungeon_team_count");
    auto *newRoute=panel.findChild<QLineEdit*>("dungeon_new_sanhuan_sanhuan_route");
    if(!check(newTeam&&newTeam->minimum()==3&&newTeam->maximum()==6&&newRoute&&newRoute->maxLength()==1024&&!newRoute->placeholderText().isEmpty(),"new dungeon configuration and route hint"))return 1;
    for(const auto &id:QStringList{"dungeon_00322b14","dungeon_0032b023"}){
        panel.selectTask(id);auto *count=panel.findChild<QDoubleSpinBox*>(id+"_count_fhlm");
        if(!check(count&&count->minimum()==0&&count->maximum()==24,"phoenix team setting"))return 1;
        count->setValue(4);
        if(!check(panel.profile().value("tasks").toObject().value(id).toObject().value("count_fhlm").toInt()==4,"phoenix team setting saved"))return 1;
    }
    for(const auto &id:QStringList{"sanshen","dungeon_002fd257","orig_0034fff0","wangling"}){
        panel.selectTask(id);auto *alt=panel.findChild<QCheckBox*>(id+"_小号模式");
        if(!check(alt,"dungeon alt-mode setting"))return 1;
        alt->setChecked(true);
        if(!check(panel.profile().value("tasks").toObject().value(id).toObject().value("小号模式").toBool(),"dungeon alt-mode saved"))return 1;
    }
    panel.selectTask("tlzz_manor_fish");QCoreApplication::sendPostedEvents(nullptr,QEvent::DeferredDelete);
    auto *fishLevel=panel.findChild<QComboBox*>("tlzz_manor_fish_zy_level");auto *fishKind=panel.findChild<QComboBox*>("tlzz_manor_fish_zy_kind");
    if(!check(fishLevel&&fishKind&&fishLevel->count()==3&&fishKind->count()==5,"manor fish choices"))return 1;
    fishLevel->setCurrentText("中熟");fishKind->setCurrentText("鲤鱼");
    const auto fish=panel.profile().value("tasks").toObject().value("tlzz_manor_fish").toObject();
    if(!check(fish.value("zy_level").toString()=="中熟"&&fish.value("zy_kind").toString()=="鲤鱼","manor fish choice values saved"))return 1;
    auto updated=panel.profile();auto taskValues=updated.value("tasks").toObject();auto yanzi=taskValues.value("yanzi").toObject();yanzi.insert("yzw_type","旧配置值");taskValues.insert("yanzi",yanzi);updated.insert("tasks",taskValues);panel.setProfile(updated);
    panel.selectTask("yanzi");QCoreApplication::sendPostedEvents(nullptr,QEvent::DeferredDelete);
    auto *difficulty=panel.findChild<QComboBox*>("yanzi_yzw_type");
    if(!check(difficulty&&difficulty->findData("普通")>=0&&difficulty->findData("高级")>=0&&difficulty->currentData().toString()=="旧配置值","saved difficulty retained"))return 1;
    if(!check(panel.findChild<QScrollArea*>("yanzi_parameter_scroll"),"parameter form scrolls"))return 1;
    auto *engine=panel.findChild<QComboBox*>("yanzi_engine");if(!check(engine&&engine->parentWidget()->isHidden(),"single engine hidden"))return 1;
    bool hasOpaque=false;for(auto *w:panel.findChildren<QToolButton*>())if(w->text()=="原参数（用途待核对）"&&!w->isChecked())hasOpaque=true;
    if(!check(!hasOpaque,"yanzi obsolete original fields removed"))return 1;
    difficulty->setCurrentText("初级");if(!check(panel.profile().value("tasks").toObject().value("yanzi").toObject().value("yzw_type").toString()=="初级","difficulty value saved"))return 1;
    panel.selectTask("tlzz_gulanyu");QCoreApplication::sendPostedEvents(nullptr,QEvent::DeferredDelete);
    auto *gem=panel.findChild<QLineEdit*>("tlzz_gulanyu_gulanyu_list");if(!check(gem&&gem->placeholderText().contains("红宝石|5"),"gem input example"))return 1;
    panel.selectTask("wait");QCoreApplication::sendPostedEvents(nullptr,QEvent::DeferredDelete);
    auto *waitKind=panel.findChild<QComboBox*>("wait_wait_kind");auto *clock=panel.findChild<QTimeEdit*>("wait_wait_time");auto *duration=panel.findChild<QDoubleSpinBox*>("wait_wait_seconds");
    if(!check(waitKind&&clock&&duration&&!clock->parentWidget()->isHidden()&&duration->parentWidget()->isHidden(),"wait time controls"))return 1;
    waitKind->setCurrentText("等待时长");if(!check(clock->parentWidget()->isHidden()&&!duration->parentWidget()->isHidden(),"wait duration visibility"))return 1;
    waitKind->setCurrentText("指定时刻");clock->setTime(QTime(7,30));
    if(!check(panel.profile().value("tasks").toObject().value("wait").toObject().value("wait_time").toString()=="07:30","wait time value saved"))return 1;
    auto legacyWait=panel.profile();auto savedTasks=legacyWait.value("tasks").toObject();auto savedWait=savedTasks.value("wait").toObject();savedWait.insert("wait_time","历史格式");savedTasks.insert("wait",savedWait);legacyWait.insert("tasks",savedTasks);
    auto oldTeam=legacyWait.value("team").toObject();oldTeam.insert("role","历史职责");legacyWait.insert("team",oldTeam);panel.setProfile(legacyWait);
    auto *role=panel.findChild<QComboBox*>("team_role");if(!check(role&&role->currentData().toString()=="历史职责","legacy team role retained"))return 1;
    role->setCurrentText("队长");if(!check(panel.profile().value("team").toObject().value("role").toString()=="队长","team role saved"))return 1;
    panel.selectTask("wait");QCoreApplication::sendPostedEvents(nullptr,QEvent::DeferredDelete);
    auto *oldClock=panel.findChild<QLineEdit*>("wait_wait_time");if(!check(oldClock&&oldClock->text()=="历史格式"&&oldClock->placeholderText().contains("08:30"),"invalid legacy wait time retained"))return 1;
    auto *listing=panel.findChild<QTableWidget*>("listingRules");QPushButton *addListing=nullptr;
    for(auto *button:panel.findChildren<QPushButton*>())if(button->text()=="添加物品规则")addListing=button;
    if(!check(listing&&addListing,"listing controls"))return 1;
    addListing->click();
    auto *place=panel.findChild<QComboBox*>("listing_place_0");if(!check(place&&place->findData("天外")>=0,"listing location choices"))return 1;
    place->setCurrentIndex(place->findData("天外"));
    if(!check(panel.profile().value("trade").toObject().value("listings").toArray()[0].toObject().value("place").toString()=="天外","listing location saved"))return 1;
    auto healerDraft=panel.profile();
    healerDraft.insert("queue",QJsonArray{QJsonObject{{"task","dungeon_00320005"},{"params",QJsonObject{{"combat",true},{"battle_system",QJsonObject{}}}}}});
    tlbb::SessionPanel healer(tlbb::GameInfo{},healerDraft);
    auto *emeiEnable=healer.findChild<QCheckBox*>("battle_emei_enabled");
    auto *emeiAttack=healer.findChild<QCheckBox*>("battle_emei_attack");
    auto *emeiThreshold=healer.findChild<QSpinBox*>("battle_emei_heal_percent");
    auto *maintenance=healer.findChild<QCheckBox*>("battle_enabled");
    if(!check(emeiEnable&&emeiAttack&&emeiThreshold&&maintenance&&!emeiAttack->isEnabled(),"Emei controls and disabled policy"))return 1;
    emeiEnable->setChecked(true);emeiAttack->setChecked(true);emeiThreshold->setValue(80);
    const auto healerBattle=healer.profile().value("battle").toObject();
    const auto queuedBattle=healer.profile().value("queue").toArray()[0].toObject().value("params").toObject().value("battle_system").toObject();
    if(!check(emeiAttack->isEnabled()&&healerBattle.value("emei_enabled").toBool()&&queuedBattle.value("emei_attack").toBool()&&queuedBattle.value("emei_heal_percent").toInt()==80,"Emei draft queue updates"))return 1;
    tlbb::SessionPanel healerRestored(tlbb::GameInfo{},QJsonDocument::fromJson(QJsonDocument(healer.profile()).toJson()).object());
    if(!check(healerRestored.findChild<QCheckBox*>("battle_emei_attack")->isChecked()&&!panel.profile().value("battle").toObject().value("emei_enabled").toBool(),"Emei role persistence and independence"))return 1;
    maintenance->setChecked(false);
    if(!check(!emeiEnable->isChecked()&&!emeiAttack->isEnabled(),"Disabling maintenance disables Emei policy"))return 1;
    emeiEnable->setChecked(true);
    if(!check(maintenance->isChecked(),"Enabling Emei enables its maintenance dependency"))return 1;
    const auto preview=qEnvironmentVariable("TLBB_UI_PREVIEW_DIR");
    if(!preview.isEmpty()){
        panel.resize(1120,710);panel.setAttribute(Qt::WA_DontShowOnScreen,true);panel.show();
        for(const auto &id:QStringList{"yanzi","tlzz_manor_fish","tlzz_gulanyu"}){
            panel.selectTask(id);QCoreApplication::sendPostedEvents(nullptr,QEvent::DeferredDelete);QCoreApplication::processEvents();
            if(!check(panel.grab().save(QDir(preview).filePath("ui-"+id+".png")),"ui preview"))return 1;
        }
        panel.hide();
    }
    return 0;
}
