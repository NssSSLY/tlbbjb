#pragma once
#include "gameplay_protocol.hpp"
#include <QJsonObject>
#include <QString>
#include <QStringList>
#include <memory>
namespace tlbb {
struct SnippetReply { int count=0; double numbers[8]{}; QString text; bool actions=false,manual=false; };
class GameplayChannel {
public:
    GameplayChannel();~GameplayChannel();
    bool open(quint32 pid,const QString &created,const QString &root,QString &error);
    bool call(gameplay::Command command,int argument,QJsonObject &state,QString &error);
    bool snippet(uint32_t id,const gameplay::SnippetArgs &args,SnippetReply &reply,QString &error);
    quintptr window() const;
private:
    bool exchange(gameplay::Packet &request,QJsonObject &state,QString &error);
    struct Impl;std::unique_ptr<Impl> p_;
};
bool validateDailySignConfig(const QJsonObject &config,QString &error);
int runGameplayProbe(const QStringList &arguments);
}
